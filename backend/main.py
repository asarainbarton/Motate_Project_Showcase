from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, timedelta
import sqlite3
import csv
import io
import json
from fastapi.responses import StreamingResponse
from transformers import pipeline

app = FastAPI(title="Emotion Journal API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize sentiment classifier with PyTorch backend
classifier = pipeline("sentiment-analysis", model="distilbert-base-uncased-finetuned-sst-2-english", framework="pt")

# Database setup
DB_PATH = "journal.db"

def get_db_connection():
    """Get database connection with proper UTF-8 encoding"""
    conn = sqlite3.connect(DB_PATH)
    # Ensure UTF-8 encoding for emoji support
    conn.execute("PRAGMA encoding = 'UTF-8'")
    conn.row_factory = sqlite3.Row  # Enable dict-like access to rows
    return conn

def init_db():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            emoji TEXT NOT NULL,
            sentiment TEXT NOT NULL,
            sentiment_score REAL NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

init_db()

class JournalEntry(BaseModel):
    text: str
    emoji: str

class JournalEntryUpdate(BaseModel):
    text: Optional[str] = None
    emoji: Optional[str] = None

@app.post("/entry")
def add_entry(entry: JournalEntry):
    # Run sentiment analysis
    result = classifier(entry.text)[0]
    sentiment = result['label']
    score = result['score']

    # Store in DB with proper UTF-8 handling
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        INSERT INTO entries (text, emoji, sentiment, sentiment_score, created_at)
        VALUES (?, ?, ?, ?, ?)
    ''', (entry.text, entry.emoji, sentiment, score, datetime.utcnow()))
    conn.commit()
    conn.close()

    return JSONResponse(
        content={"message": "Entry added", "sentiment": sentiment, "score": score},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/stats/weekly")
def get_weekly_stats():
    conn = get_db_connection()
    c = conn.cursor()
    one_week_ago = datetime.utcnow() - timedelta(days=7)
    c.execute('''
        SELECT emoji, COUNT(*) FROM entries
        WHERE created_at >= ?
        GROUP BY emoji
    ''', (one_week_ago,))
    data = c.fetchall()
    conn.close()
    
    weekly_counts = {row[0]: row[1] for row in data}
    return JSONResponse(
        content={"weekly_counts": weekly_counts},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/stats/common_emotions")
def get_common_emotions():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        SELECT emoji, COUNT(*) as cnt FROM entries
        GROUP BY emoji
        ORDER BY cnt DESC
        LIMIT 5
    ''')
    data = c.fetchall()
    conn.close()
    
    common_emotions = [{"emoji": row[0], "count": row[1]} for row in data]
    return JSONResponse(
        content={"common_emotions": common_emotions},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/entries")
def get_entries(limit: int = 50, offset: int = 0):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        SELECT id, text, emoji, sentiment, sentiment_score, created_at 
        FROM entries 
        ORDER BY created_at DESC 
        LIMIT ? OFFSET ?
    ''', (limit, offset))
    rows = c.fetchall()
    conn.close()
    
    entries = []
    for row in rows:
        entries.append({
            "id": row[0],
            "text": row[1],
            "emoji": row[2],
            "sentiment": row[3],
            "sentiment_score": row[4],
            "created_at": row[5]
        })
    
    return JSONResponse(
        content={"entries": entries},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/entries/{entry_id}")
def get_entry(entry_id: int):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT id, text, emoji, sentiment, sentiment_score, created_at FROM entries WHERE id = ?', (entry_id,))
    row = c.fetchone()
    conn.close()
    
    if not row:
        raise HTTPException(status_code=404, detail="Entry not found")
    
    entry_data = {
        "id": row[0],
        "text": row[1],
        "emoji": row[2],
        "sentiment": row[3],
        "sentiment_score": row[4],
        "created_at": row[5]
    }
    
    return JSONResponse(
        content=entry_data,
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.put("/entries/{entry_id}")
def update_entry(entry_id: int, entry: JournalEntryUpdate):
    conn = get_db_connection()
    c = conn.cursor()
    
    # Check if entry exists
    c.execute('SELECT id FROM entries WHERE id = ?', (entry_id,))
    if not c.fetchone():
        conn.close()
        raise HTTPException(status_code=404, detail="Entry not found")
    
    # Update fields that are provided
    updates = []
    params = []
    
    if entry.text is not None:
        # Re-run sentiment analysis if text is updated
        result = classifier(entry.text)[0]
        updates.extend(['text = ?', 'sentiment = ?', 'sentiment_score = ?'])
        params.extend([entry.text, result['label'], result['score']])
    
    if entry.emoji is not None:
        updates.append('emoji = ?')
        params.append(entry.emoji)
    
    if updates:
        params.append(entry_id)
        query = f"UPDATE entries SET {', '.join(updates)} WHERE id = ?"
        c.execute(query, params)
        conn.commit()
    
    conn.close()
    return JSONResponse(
        content={"message": "Entry updated successfully"},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.delete("/entries/{entry_id}")
def delete_entry(entry_id: int):
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('DELETE FROM entries WHERE id = ?', (entry_id,))
    
    if c.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Entry not found")
    
    conn.commit()
    conn.close()
    return JSONResponse(
        content={"message": "Entry deleted successfully"},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/stats/sentiment_distribution")
def get_sentiment_distribution():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('''
        SELECT sentiment, COUNT(*) as count FROM entries
        GROUP BY sentiment
    ''')
    data = c.fetchall()
    conn.close()
    
    sentiment_distribution = {row[0]: row[1] for row in data}
    return JSONResponse(
        content={"sentiment_distribution": sentiment_distribution},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.get("/export/csv")
def export_csv():
    conn = get_db_connection()
    c = conn.cursor()
    c.execute('SELECT text, emoji, sentiment, sentiment_score, created_at FROM entries')
    rows = c.fetchall()
    conn.close()

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(['text', 'emoji', 'sentiment', 'sentiment_score', 'created_at'])
    
    # Ensure proper UTF-8 encoding for CSV export
    for row in rows:
        writer.writerow([
            row[0],  # text
            row[1],  # emoji (should now be properly encoded)
            row[2],  # sentiment
            row[3],  # sentiment_score
            row[4]   # created_at
        ])
    
    output.seek(0)

    return StreamingResponse(
        io.StringIO(output.getvalue()), 
        media_type="text/csv; charset=utf-8",
        headers={
            "Content-Disposition": "attachment; filename=journal_entries.csv",
            "Content-Type": "text/csv; charset=utf-8"
        }
    )

# Emotion Journal - AI Mood Detection App

A real-time emotion journal application with AI-powered mood detection, built with Flutter (frontend) and FastAPI (backend).

## Features

### Core Functionality
- **Journal Entry Creation**: Write daily thoughts and feelings
- **Emoji Mood Selection**: Choose from 8 different mood emojis
- **AI Sentiment Analysis**: Automatic mood detection using DistilBERT
- **Advanced Analytics**: Multiple chart types and statistics
- **Cross-Platform**: Flutter app works on iOS and Android
- **Data Export**: Export journal entries to CSV

### Enhanced Features
- **Weekly Mood Distribution**: Bar chart showing mood patterns
- **Most Common Emotions**: Track your frequent emotional states
- **AI Sentiment Distribution**: Pie chart of positive/negative/neutral sentiments
- **Entry History**: View, edit, and delete past entries
- **Real-time Analysis**: Instant AI feedback on your entries
- **Modern UI**: Clean, intuitive design with smooth animations

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter/Dart
- **Charts**: charts_flutter for data visualization
- **HTTP**: http package for API communication
- **Storage**: path_provider for file operations
- **UI**: Material Design with custom theming

### Backend (Python)
- **Framework**: FastAPI
- **AI/ML**: Transformers (DistilBERT) + PyTorch
- **Database**: SQLite
- **API**: RESTful API with automatic documentation
- **CORS**: Cross-origin resource sharing enabled

### AI Model
- **Model**: DistilBERT (distilbert-base-uncased-finetuned-sst-2-english)
- **Task**: Sentiment Analysis
- **Output**: Positive/Negative classification with confidence scores

## Getting Started

### Prerequisites
- Python 3.8+
- Flutter SDK 3.0+
- Git

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment** (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the server**:
   ```bash
   python start_server.py
   ```
   
   Or manually:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

5. **Verify installation**:
   - API: http://localhost:8000
   - Documentation: http://localhost:8000/docs

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   flutter run -d chrome    # Web
   flutter run -d ios       # iOS Simulator
   flutter run -d android   # Android Emulator
   ```

## App Screens

### 1. Journal Entry Screen
- **Purpose**: Create new journal entries
- **Features**: 
  - Multi-line text input
  - 8 emoji mood selectors
  - Real-time AI sentiment analysis
  - Loading states and error handling

### 2. Entry History Screen
- **Purpose**: View and manage past entries
- **Features**:
  - Chronological list of all entries
  - Edit existing entries
  - Delete entries with confirmation
  - Sentiment analysis results display
  - Pull-to-refresh functionality

### 3. Analytics Dashboard
- **Purpose**: Visualize mood patterns and trends
- **Features**:
  - **Weekly Tab**: Bar chart of mood distribution
  - **Common Tab**: Most frequent emotions with progress bars
  - **Sentiment Tab**: AI analysis pie chart with legend
  - Export to CSV functionality
  - Refresh data capability

## API Endpoints

### Journal Entries
- `POST /entry` - Create new journal entry
- `GET /entries` - Get all entries (paginated)
- `GET /entries/{id}` - Get specific entry
- `PUT /entries/{id}` - Update entry
- `DELETE /entries/{id}` - Delete entry

### Statistics
- `GET /stats/weekly` - Weekly mood counts
- `GET /stats/common_emotions` - Most common emotions
- `GET /stats/sentiment_distribution` - AI sentiment analysis distribution

### Data Export
- `GET /export/csv` - Export all entries to CSV

## Database Schema

```sql
CREATE TABLE entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL,
    emoji TEXT NOT NULL,
    sentiment TEXT NOT NULL,           -- AI-detected sentiment
    sentiment_score REAL NOT NULL,     -- Confidence score (0-1)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## UI/UX Features

### Design System
- **Color Scheme**: Blue primary with grey accents
- **Typography**: Roboto font family
- **Cards**: Elevated cards with rounded corners
- **Animations**: Smooth transitions and loading states

### User Experience
- **Responsive Design**: Adapts to different screen sizes
- **Error Handling**: User-friendly error messages
- **Loading States**: Visual feedback during operations
- **Accessibility**: Proper contrast and touch targets

## Configuration

### Backend Configuration
- **Database**: SQLite file (`journal.db`)
- **CORS**: Enabled for all origins (configure for production)
- **Model**: DistilBERT automatically downloaded on first run

### Frontend Configuration
- **API Base URL**: `http://10.0.2.2:8000` (Android emulator)
- **iOS Simulator**: Change to `http://localhost:8000`
- **Web**: Change to `http://localhost:8000`

## Data Analytics

### Mood Tracking
- Weekly mood distribution charts
- Most common emotional states
- Sentiment analysis trends over time

### AI Insights
- Automatic sentiment classification
- Confidence scores for each analysis
- Positive/negative/neutral distribution

## Deployment

### Backend Deployment
1. **Production Settings**:
   - Configure CORS origins
   - Set up proper database (PostgreSQL recommended)
   - Use environment variables for configuration

2. **Docker Deployment**:
   ```dockerfile
   FROM python:3.9
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . .
   CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
   ```

### Frontend Deployment
1. **Web**: `flutter build web`
2. **Android**: `flutter build apk`
3. **iOS**: `flutter build ios`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Hugging Face**: For the DistilBERT model
- **Flutter Team**: For the amazing framework
- **FastAPI**: For the excellent Python web framework
- **Charts Flutter**: For beautiful data visualizations

## Support

If you encounter any issues or have questions:
1. Check the API documentation at `/docs`
2. Review the console logs for errors
3. Ensure all dependencies are properly installed
4. Verify the backend server is running

---

**Happy Journaling!**

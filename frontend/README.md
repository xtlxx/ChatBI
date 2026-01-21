# Enterprise AI SQL Analytics Platform

A robust, multi-tenant Text-to-SQL analysis platform where users can configure multiple database connections and LLM models, and perform natural language data analysis.

## 🚀 Features

- **Multi-tenant Architecture**: Secure user authentication and data isolation
- **Database Management**: Support for MySQL, PostgreSQL, and MS SQL Server
- **LLM Integration**: Compatible with OpenAI, Qwen, and DeepSeek models
- **Real-time Streaming**: Server-Sent Events (SSE) for responsive chat experience
- **Data Visualization**: ECharts integration for dynamic chart generation
- **Enterprise UI**: Clean, professional dashboard design with Shadcn/UI
- **Type Safety**: Full TypeScript implementation

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **State Management**: Zustand
- **UI Library**: Shadcn/UI (Radix UI + Tailwind CSS)
- **Forms**: React Hook Form + Zod validation
- **Visualization**: ECharts-for-React
- **Markdown**: react-markdown + syntax highlighting

### Backend
- **Framework**: FastAPI (Python)
- **AI/LLM**: LangChain with multiple provider support
- **Database**: SQL Database Toolkit
- **Authentication**: JWT-based security

## 📋 Prerequisites

- Node.js 18+ 
- Python 3.9+
- MySQL/PostgreSQL/MS SQL Server database

## 🚀 Quick Start

### 1. Clone and Setup Frontend

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env.local

# Start development server
npm run dev
```

### 2. Configure Environment Variables

Create `.env.local` in the frontend directory:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
```

### 3. Setup Backend

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env

# Start FastAPI server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Configure Backend Environment

Edit `.env` in the backend directory:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=your_database

# LLM Configuration
QWEN_API_BASE=https://api.modelscope.cn/v1
DASHSCOPE_API_KEY=your_qwen_api_key
QWEN_MODEL_NAME=qwen-plus
LLM_TEMPERATURE=0.1
MAX_AGENT_ITERATIONS=15
```

## 🏗️ Project Structure

```
frontend/
├── app/                    # Next.js App Router
│   ├── chat/              # Main chat interface
│   ├── settings/          # Configuration management
│   ├── login/             # Authentication
│   ├── register/          # User registration
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Home page
├── components/
│   ├── ui/                # Shadcn/UI components
│   └── ...                # Custom components
├── hooks/                 # Custom React hooks
│   └── useChatStream.ts   # SSE streaming hook
├── lib/                   # Utilities
│   ├── api.ts            # API client with JWT interceptor
│   ├── api-services.ts   # API service functions
│   └── utils.ts          # Helper functions
├── store/                 # Zustand store
│   └── useAppStore.ts    # Global state management
├── types/                 # TypeScript definitions
│   └── index.ts          # Type interfaces
└── package.json
```

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **API Interceptor**: Automatic JWT injection for all requests
- **Payload Security**: User identity extracted from JWT (not request body)
- **Data Sanitization**: Sensitive data never logged or exposed
- **Input Validation**: Zod schema validation for all forms

## 📊 Core Components

### Chat Interface (`/chat`)
- Real-time streaming responses
- Collapsible thought process display
- SQL query visualization
- Dynamic chart rendering
- Session history management

### Settings (`/settings`)
- Database connection management
- LLM configuration
- Connection testing
- CRUD operations with validation

### Authentication (`/login`, `/register`)
- Secure JWT-based authentication
- Form validation
- Error handling
- Auto-redirect after login

## 🎨 UI/UX Features

- **Enterprise Design**: Professional, high-density interface
- **Responsive Layout**: Works on desktop and tablet
- **Loading States**: Clear feedback during operations
- **Error Messages**: Detailed error reporting with codes
- **Dark Mode Support**: Built-in theme switching capability

## 🔧 Development

### Running Tests

```bash
# Frontend
npm run test

# Backend
pytest
```

### Building for Production

```bash
# Frontend
npm run build

# Backend
# Production deployment with Gunicorn/Uvicorn
```

## 📝 API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user

### Database Connections
- `GET /connections` - List connections
- `POST /connections` - Create connection
- `PUT /connections/{id}` - Update connection
- `DELETE /connections/{id}` - Delete connection
- `POST /connections/test` - Test connection

### LLM Configurations
- `GET /llm-configs` - List LLM configs
- `POST /llm-configs` - Create LLM config
- `PUT /llm-configs/{id}` - Update LLM config
- `DELETE /llm-configs/{id}` - Delete LLM config
- `POST /llm-configs/test` - Test LLM config

### Chat
- `POST /query/stream` - Streaming chat query
- `POST /query` - Non-streaming query
- `GET /chat/sessions` - List chat sessions
- `POST /chat/sessions` - Create chat session

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the existing issues
2. Create a new issue with detailed description
3. Include error logs and environment details

---

**Built with ❤️ for enterprise data analytics**

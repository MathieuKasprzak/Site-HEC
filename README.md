# � Waiting List

A simple Next.js application to collect names and emails for your waiting list.

## ✨ Features

- Clean, modern single-page design
- Collect Full Name and Email
- Stores data in Supabase
- Success confirmation message
- Responsive design (mobile + desktop)

## 🚀 Tech Stack

- **Framework**: Next.js 15 with React 19
- **Styling**: Tailwind CSS 4
- **Backend**: Supabase (PostgreSQL)
- **Language**: TypeScript
- **Deployment**: Ready for Vercel

## 📋 Prerequisites

- Node.js 18+ installed
- A Supabase account and project
- Supabase credentials (URL and Anon Key)

## 🛠️ Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Your `.env` file is already configured with:

```env
NEXT_PUBLIC_SUPABASE_URL=https://dqfbhilgrmqvclbxuhwf.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

### 3. Set Up Supabase Database

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Run the SQL script from `supabase_waiting_list_simple.sql`

This will create the `users` table with:
- `full_name` - User's full name
- `email` - User's email address
- `created_at` - Timestamp of when they joined

### 4. Run the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## 📁 Project Structure

```
src/
├── app/
│   ├── page.tsx           # Main waiting list page
│   ├── layout.tsx         # Root layout
│   └── globals.css        # Global styles
└── lib/
    └── supabase.ts        # Supabase client configuration
```

## 🎨 Design

- Clean white background with gray accents
- Blue gradient button for submissions
- Professional, modern aesthetic inspired by Guepard.run
- Rounded corners and subtle shadows
- Smooth transitions and hover effects

## 📊 View Your Data

To view all waiting list entries in Supabase:

```sql
SELECT 
  full_name AS "Full Name",
  email AS "Email",
  created_at AS "Joined At"
FROM users
ORDER BY created_at DESC;
```

## 🚢 Deployment

### Deploy to Vercel

```bash
vercel deploy
```

Make sure to add your environment variables in the Vercel dashboard:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## 📝 Features

- ✅ Simple one-page design
- ✅ Name and email collection
- ✅ Real-time database storage
- ✅ Success confirmation
- ✅ Email validation
- ✅ Duplicate email prevention
- ✅ Responsive design
- ✅ Loading states

## 📄 License

MIT License - Feel free to use this project for your waiting list!

---

Made with ❤️ using Next.js and Supabase

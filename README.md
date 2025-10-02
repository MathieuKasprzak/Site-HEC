# 🐾 Animal Portrait Studio

A Next.js application that allows customers to create magical, AI-generated photos of themselves with their favorite animals.

## ✨ Features

1. **User Sign Up** - Customers create an account with their full name and email
2. **Photo Upload** - Upload a personal photo with drag-and-drop support
3. **Animal Selection** - Choose from 18 different animals to appear in the photo
4. **AI Generation** - Generate a custom photo with the selected animal (simulation in demo)
5. **Purchase Options** - Three pricing tiers: Digital Download, Print + Digital, and Premium Package

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

### 1. Clone and Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Create a `.env.local` file in the root directory:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Set Up Supabase Database

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Run the SQL migration script from `supabase_migration.sql`

This will create the following tables:
- `users` - Store user information
- `generated_photos` - Track generated photos
- `purchases` - Record purchase transactions

### 4. Run the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## 📁 Project Structure

```
src/
├── app/
│   ├── page.tsx           # Main app with step orchestration
│   ├── layout.tsx         # Root layout
│   └── globals.css        # Global styles
├── components/
│   ├── SignUpStep.tsx     # Step 1: User registration
│   ├── UploadPhotoStep.tsx # Step 2: Photo upload
│   ├── ChooseAnimalStep.tsx # Step 3: Animal selection
│   ├── GeneratePhotoStep.tsx # Step 4: AI generation
│   └── PurchaseStep.tsx   # Step 5: Payment & download
└── lib/
    └── supabase.ts        # Supabase client configuration
```

## 🎨 User Flow

1. **Sign Up** → User enters full name and email
2. **Upload Photo** → User uploads their photo (drag & drop supported)
3. **Choose Animal** → User selects from 18 animals
4. **Generate** → AI generates the photo (simulated in demo)
5. **Purchase** → Choose from 3 pricing tiers and complete purchase

## 💳 Pricing Tiers

- **Digital Download** - $9.99
  - High-resolution digital file
  - Instant download
  - Email delivery

- **Print + Digital** - $24.99 (Most Popular)
  - Everything in Digital
  - 8x10 printed photo
  - Premium quality paper

- **Premium Package** - $49.99
  - Everything in Print
  - Multiple size options
  - Framed photo
  - Express shipping

## 🔮 Future Enhancements

To make this production-ready, you would need to:

1. **AI Integration**: Connect to an AI image generation API (DALL-E, Stable Diffusion, Midjourney)
2. **Payment Processing**: Integrate Stripe or PayPal for real payments
3. **File Storage**: Upload photos to Supabase Storage or AWS S3
4. **Email Service**: Set up email delivery with SendGrid or Resend
5. **Authentication**: Add proper user authentication with Supabase Auth
6. **Admin Dashboard**: Create a dashboard to manage orders and users

## 📝 Notes

- This is a demo application with simulated AI generation
- Payment processing is simulated and would need Stripe/PayPal integration
- The generated image currently shows the original photo as a placeholder
- Row Level Security (RLS) policies are basic and should be enhanced for production

## 🚢 Deployment

### Deploy to Vercel

```bash
vercel deploy
```

Make sure to add your environment variables in the Vercel dashboard.

## 📄 License

MIT License - Feel free to use this project as a template for your own applications!

---

Made with ❤️ using Next.js and Supabase

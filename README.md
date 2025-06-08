# MyWebsite - Modern Next.js Site with Authentication

A modern, responsive website built with Next.js, React, and Tailwind CSS with full authentication support using Auth.js (NextAuth.js v5). This project demonstrates best practices in modern web development with secure authentication and GitHub Codespaces support.

## Features

### Core Framework
- ⚡ Built with Next.js 15 and React 19
- 🎨 Styled with Tailwind CSS for responsive design
- 📱 Mobile-first responsive design
- 🧩 Reusable component architecture
- ✅ Form validation with user feedback
- 🔄 Loading states and smooth transitions
- 📍 Client-side routing with Next.js App Router
- 🎯 SEO optimized with proper meta tags
- ♿ Accessibility compliant
- 🔧 ESLint configured for code quality

### Authentication & Security
- 🔐 Full authentication system with Auth.js (NextAuth.js v5)
- 🔑 Email/password authentication with secure password hashing
- 🌐 OAuth integration (GitHub, Google)
- 🛡️ Route protection middleware
- 👤 User dashboard and profile management
- 🔄 Session management with secure cookies
- 📊 SQLite database with Prisma ORM

### GitHub Codespaces Support
- 🚀 Optimized for GitHub Codespaces development
- 🌍 Automatic URL detection and configuration
- ⚙️ Environment variable management
- 🔗 OAuth callback URL automation
- 📝 Comprehensive setup documentation

## Project Structure

```
src/
├── app/                 # Next.js App Router pages
│   ├── about/          # About page
│   ├── contact/        # Contact page with form
│   ├── globals.css     # Global styles
│   ├── layout.js       # Root layout with navigation
│   └── page.js         # Home page
└── components/         # Reusable components
    ├── Navigation.js   # Responsive navigation
    ├── Footer.js       # Site footer
    └── LoadingSpinner.js # Loading component
```

## Getting Started

### For GitHub Codespaces (Recommended)

1. **Quick Start**: Use the automated setup script
```bash
./start_in_codespaces.sh
```

This script will:
- Detect your Codespace environment
- Configure the correct URLs automatically
- Set up environment variables
- Provide OAuth configuration instructions
- Start the development server

2. **Manual Setup**: If you prefer manual configuration
```bash
npm install
npm run dev
```

Then configure your environment variables and OAuth providers as described in the [GitHub Codespaces Guide](.vibe/docs/GITHUB_CODESPACES_NEXTJS_AUTH_GUIDE.md).

### For Local Development

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env.local
# Edit .env.local with your configuration
```

3. Run the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) to view the site.

### Environment Configuration

Required environment variables:
- `NEXTAUTH_SECRET` - Generate with `openssl rand -base64 32`
- `AUTH_GITHUB_ID` - GitHub OAuth App ID
- `AUTH_GITHUB_SECRET` - GitHub OAuth App Secret
- `AUTH_GOOGLE_ID` - Google OAuth Client ID (optional)
- `AUTH_GOOGLE_SECRET` - Google OAuth Client Secret (optional)

For detailed setup instructions, see:
- [Authentication Setup Guide](.vibe/docs/AUTHENTICATION_SETUP_GUIDE.md)
- [GitHub Codespaces Configuration Guide](.vibe/docs/GITHUB_CODESPACES_NEXTJS_AUTH_GUIDE.md)

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

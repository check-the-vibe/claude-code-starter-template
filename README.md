# MyWebsite - Modern Next.js Site

A modern, responsive website built with Next.js, React, and Tailwind CSS. This project demonstrates best practices in modern web development with a clean, professional design.

## Features

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

1. Install dependencies:
```bash
npm install
```

2. Run the development server:
```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000) to view the site.

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

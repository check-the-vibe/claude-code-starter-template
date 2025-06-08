export default function About() {
  return (
    <div className="min-h-screen p-8 pb-20 gap-16 sm:p-20">
      <main className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 text-center">About Us</h1>
        <div className="prose lg:prose-xl mx-auto">
          <p className="text-lg leading-relaxed mb-6">
            Welcome to our Next.js website! We are passionate about creating 
            modern, fast, and responsive web experiences using the latest 
            technologies.
          </p>
          <p className="text-lg leading-relaxed mb-6">
            This website is built with Next.js, React, and Tailwind CSS, 
            showcasing best practices in modern web development. Our team 
            focuses on delivering high-quality solutions that are both 
            user-friendly and developer-friendly.
          </p>
          <p className="text-lg leading-relaxed">
            Whether you&apos;re here to learn about our services, explore our 
            projects, or get in touch with us, we&apos;re excited to connect 
            with you!
          </p>
        </div>
      </main>
    </div>
  );
}
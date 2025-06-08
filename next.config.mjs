/** @type {import('next').NextConfig} */
const nextConfig = {
  // Electron-specific configuration
  output: process.env.NODE_ENV === 'production' && process.env.ELECTRON === 'true' 
    ? 'export' 
    : undefined,
  
  // Configure trailing slash for static export
  trailingSlash: process.env.ELECTRON === 'true',
  
  // Disable image optimization for Electron builds
  images: {
    unoptimized: process.env.ELECTRON === 'true'
  },
  
  // Custom dist directory for Electron builds
  distDir: process.env.ELECTRON === 'true' ? '../app' : '.next',
  
  // Webpack configuration for Electron compatibility
  webpack: (config, { isServer }) => {
    // Handle Electron-specific modules
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
        path: false,
        os: false,
      };
    }
    
    return config;
  },
  
  // Remove experimental.esmExternals for Turbopack compatibility
  // experimental: {
  //   esmExternals: false,
  // },
};

export default nextConfig;

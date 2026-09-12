import React from 'react';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';

function App() {
  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      <Navbar />
      <main className="flex-1">
        <Dashboard />
      </main>
      <footer className="py-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>
    </div>
  );
}

export default App;
import React, { useState } from 'react';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';
import { VenuesPage } from './pages/VenuesPage';
import { ResourcesPage } from './pages/ResourcesPage';
import { PaymentsPage } from './pages/PaymentsPage';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 flex flex-col font-sans selection:bg-sky-500 selection:text-white">
      <Navbar currentTab={activeTab} onTabChange={setActiveTab} />
      
      <main className="flex-1">
        {activeTab === 'dashboard' && <Dashboard />}
        {activeTab === 'venues' && <VenuesPage />}
        {activeTab === 'resources' && <ResourcesPage />}
        {activeTab === 'payments' && <PaymentsPage />}
      </main>

      <footer className="py-5 text-center text-xs text-slate-500 border-t border-slate-800 bg-slate-950/80">
        <div className="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-2">
          <span>SE3090 Software Engineering Frameworks • EventCraft AI Multi-Agent Platform</span>
          <span className="text-slate-600">Enterprise Cloud & Autonomous Agents Cluster v2.4</span>
        </div>
      </footer>
    </div>
  );
}

export default App;
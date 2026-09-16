import React, { useState } from 'react';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';
import { VenuesPage } from './pages/VenuesPage';
import { ResourcesPage } from './pages/ResourcesPage';
import { PaymentsPage } from './pages/PaymentsPage';

import { VendorPortal } from './pages/VendorPortal';

function App() {
  const [currentPortal, setCurrentPortal] = useState<'manager' | 'vendor'>('manager');
  const [activeTab, setActiveTab] = useState('dashboard');

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      <Navbar 
        currentTab={activeTab} 
        onTabChange={setActiveTab} 
        currentPortal={currentPortal}
        onPortalChange={setCurrentPortal}
      />
      
      <main className="flex-1">
        {currentPortal === 'manager' ? (
          <>
            <div className={activeTab === 'dashboard' ? 'block' : 'hidden'}><Dashboard /></div>
            <div className={activeTab === 'venues' ? 'block' : 'hidden'}><VenuesPage /></div>
            <div className={activeTab === 'resources' ? 'block' : 'hidden'}><ResourcesPage /></div>
            <div className={activeTab === 'payments' ? 'block' : 'hidden'}><PaymentsPage /></div>
          </>
        ) : (
          <VendorPortal onSwitchToManager={() => {
            setCurrentPortal('manager');
            setActiveTab('venues');
          }} />
        )}
      </main>

      <footer className="py-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>
    </div>
  );
}

export default App;
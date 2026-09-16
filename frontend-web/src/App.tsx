import React, { useState, useEffect } from 'react';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';
import { VenuesPage } from './pages/VenuesPage';
import { ResourcesPage } from './pages/ResourcesPage';
import { PaymentsPage } from './pages/PaymentsPage';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { authService } from './services/authService';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showRegister, setShowRegister] = useState(false);

  useEffect(() => {
    setIsAuthenticated(authService.isLoggedIn());
  }, []);

  const handleLoginSuccess = () => {
    setIsAuthenticated(true);
    setShowRegister(false);
    setActiveTab('dashboard');
  };

  const handleLogout = () => {
    authService.logout();
    setIsAuthenticated(false);
  };

  if (!isAuthenticated) {
    if (showRegister) {
      return <Register onNavigateLogin={() => setShowRegister(false)} />;
    }
    return <Login onLoginSuccess={handleLoginSuccess} onNavigateRegister={() => setShowRegister(true)} />;
  }

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      <Navbar currentTab={activeTab} onTabChange={setActiveTab} onLogout={handleLogout} />
      
      <main className="flex-1">
        <div className={activeTab === 'dashboard' ? 'block' : 'hidden'}><Dashboard /></div>
        <div className={activeTab === 'venues' ? 'block' : 'hidden'}><VenuesPage /></div>
        <div className={activeTab === 'resources' ? 'block' : 'hidden'}><ResourcesPage /></div>
        <div className={activeTab === 'payments' ? 'block' : 'hidden'}><PaymentsPage /></div>
      </main>

      <footer className="py-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>
    </div>
  );
}

export default App;
import React, { useState, useEffect } from 'react';
import { Navbar } from './components/Navbar';
import { Dashboard } from './pages/Dashboard';
import { VenuesPage } from './pages/VenuesPage';
import { VendorsPage } from './pages/VendorsPage';
import { ResourcesPage } from './pages/ResourcesPage';
import { PaymentsPage } from './pages/PaymentsPage';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { authService } from './services/authService';
import { VendorPortal } from './pages/VendorPortal';

function App() {
  const [userRole, setUserRole] = useState<'Manager' | 'Vendor' | 'Customer' | 'Guest'>('Guest');
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authView, setAuthView] = useState<'none' | 'login' | 'register'>('none');

  const refreshAuth = () => {
    const loggedIn = authService.isLoggedIn();
    setIsAuthenticated(loggedIn);
    if (loggedIn) {
      const role = authService.getUserRole();
      if (role === 'Vendor') setUserRole('Vendor');
      else if (role === 'Customer') setUserRole('Customer');
      else setUserRole('Manager');
    } else {
      setUserRole('Guest');
    }
  };

  useEffect(() => {
    refreshAuth();
  }, []);

  const handleLoginSuccess = () => {
    refreshAuth();
    setAuthView('none');
    setActiveTab('dashboard');
  };

  const handleLogout = () => {
    authService.logout();
    refreshAuth();
    setActiveTab('dashboard');
  };

  // Full-screen auth view if explicitly navigated to login or register
  if (authView === 'login') {
    return (
      <Login 
        onLoginSuccess={handleLoginSuccess} 
        onNavigateRegister={() => setAuthView('register')} 
      />
    );
  }

  if (authView === 'register') {
    return (
      <Register 
        onNavigateLogin={() => setAuthView('login')} 
      />
    );
  }

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      <Navbar 
        currentTab={activeTab} 
        onTabChange={setActiveTab} 
        userRole={userRole}
        onLogout={handleLogout}
        onOpenLogin={() => setAuthView('login')}
        onOpenRegister={() => setAuthView('register')}
      />
      
      <main className="flex-1">
        {userRole === 'Vendor' ? (
          <VendorPortal />
        ) : userRole === 'Manager' ? (
          <>
            <div className={activeTab === 'dashboard' ? 'block' : 'hidden'}>
              <Dashboard 
                onAuthChange={refreshAuth}
                onNavigateLogin={() => setAuthView('login')}
                onNavigateRegister={() => setAuthView('register')}
              />
            </div>
            <div className={activeTab === 'venues' ? 'block' : 'hidden'}><VenuesPage /></div>
            <div className={activeTab === 'vendors' ? 'block' : 'hidden'}><VendorsPage /></div>
            <div className={activeTab === 'resources' ? 'block' : 'hidden'}><ResourcesPage /></div>
            <div className={activeTab === 'payments' ? 'block' : 'hidden'}><PaymentsPage /></div>
          </>
        ) : (
          /* Customer / Guest Client View */
          <>
            <div className={activeTab === 'dashboard' ? 'block' : 'hidden'}>
              <Dashboard 
                onAuthChange={refreshAuth}
                onNavigateLogin={() => setAuthView('login')}
                onNavigateRegister={() => setAuthView('register')}
              />
            </div>
            <div className={activeTab === 'venues' ? 'block' : 'hidden'}><VenuesPage /></div>
          </>
        )}
      </main>

      <footer className="py-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>
    </div>
  );
}

export default App;
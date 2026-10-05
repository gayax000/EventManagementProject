import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Dashboard } from './pages/Dashboard';
import { VenuesPage } from './pages/VenuesPage';
import { VendorsPage } from './pages/VendorsPage';
import { ResourcesPage } from './pages/ResourcesPage';
import { PaymentsPage } from './pages/PaymentsPage';
import { Login } from './pages/Login';
import { authService } from './services/authService';
import { VendorPortal } from './pages/VendorPortal';

function AppContent() {
  const [userRole, setUserRole] = useState<'Manager' | 'Vendor' | 'Customer'>('Manager');
  const [isAuthenticated, setIsAuthenticated] = useState(authService.isLoggedIn());
  const navigate = useNavigate();
  const location = useLocation();

  const refreshAuth = () => {
    const loggedIn = authService.isLoggedIn();
    setIsAuthenticated(loggedIn);
    if (loggedIn) {
      const role = authService.getUserRole();
      if (role === 'Vendor') setUserRole('Vendor');
      else if (role === 'Customer') setUserRole('Customer');
      else setUserRole('Manager');
    }
  };

  useEffect(() => {
    refreshAuth();
  }, []);

  const handleLoginSuccess = () => {
    refreshAuth();
    const role = authService.getUserRole();
    if (role === 'Vendor') {
      navigate('/vendor-portal');
    } else {
      navigate('/dashboard');
    }
  };

  const handleLogout = () => {
    authService.logout();
    refreshAuth();
    navigate('/login');
  };

  // Derive active tab from current URL pathname
  const getCurrentTab = () => {
    const path = location.pathname.replace(/^\//, '').toLowerCase();
    if (path.startsWith('venues')) return 'venues';
    if (path.startsWith('vendors')) return 'vendors';
    if (path.startsWith('resources')) return 'resources';
    if (path.startsWith('payments')) return 'payments';
    if (path.startsWith('vendor-portal')) return 'vendor-portal';
    return 'dashboard';
  };

  const currentTab = getCurrentTab();
  const isLoginPage = location.pathname.toLowerCase() === '/login';

  return (
    <div className="min-h-screen bg-slate-100 flex flex-col">
      {!isLoginPage && isAuthenticated && (
        <Navbar 
          currentTab={currentTab} 
          onTabChange={(tab) => navigate(tab === 'vendor-portal' ? '/vendor-portal' : `/${tab}`)} 
          userRole={userRole}
          onLogout={handleLogout}
        />
      )}
      
      <main className="flex-1">
        <Routes>
          {/* Public / Auth Route */}
          <Route 
            path="/login" 
            element={
              isAuthenticated ? (
                <Navigate to={userRole === 'Vendor' ? '/vendor-portal' : '/dashboard'} replace />
              ) : (
                <Login onLoginSuccess={handleLoginSuccess} />
              )
            } 
          />

          {/* Manager & Client Dashboard */}
          <Route 
            path="/dashboard" 
            element={
              !isAuthenticated ? (
                <Navigate to="/login" replace />
              ) : userRole === 'Vendor' ? (
                <Navigate to="/vendor-portal" replace />
              ) : (
                <Dashboard onAuthChange={refreshAuth} />
              )
            } 
          />

          {/* Venues & Banquet Halls Catalog */}
          <Route 
            path="/venues" 
            element={
              !isAuthenticated ? (
                <Navigate to="/login" replace />
              ) : (
                <VenuesPage />
              )
            } 
          />

          {/* Vendors Management (Manager Only) */}
          <Route 
            path="/vendors" 
            element={
              <ProtectedRoute 
                isAuthenticated={isAuthenticated} 
                userRole={userRole} 
                allowedRoles={['Manager']} 
                onFallbackTab={(tab) => navigate(`/${tab}`)}
              >
                <VendorsPage />
              </ProtectedRoute>
            } 
          />

          {/* Resources & AI Rules (Manager Only) */}
          <Route 
            path="/resources" 
            element={
              <ProtectedRoute 
                isAuthenticated={isAuthenticated} 
                userRole={userRole} 
                allowedRoles={['Manager']} 
                onFallbackTab={(tab) => navigate(`/${tab}`)}
              >
                <ResourcesPage />
              </ProtectedRoute>
            } 
          />

          {/* Payments & Financial Settlement (Manager Only) */}
          <Route 
            path="/payments" 
            element={
              <ProtectedRoute 
                isAuthenticated={isAuthenticated} 
                userRole={userRole} 
                allowedRoles={['Manager']} 
                onFallbackTab={(tab) => navigate(`/${tab}`)}
              >
                <PaymentsPage />
              </ProtectedRoute>
            } 
          />

          {/* Dedicated Vendor Supplier Portal */}
          <Route 
            path="/vendor-portal" 
            element={
              <ProtectedRoute 
                isAuthenticated={isAuthenticated} 
                userRole={userRole} 
                allowedRoles={['Vendor', 'Manager']} 
                onFallbackTab={(tab) => navigate(`/${tab}`)}
              >
                <VendorPortal />
              </ProtectedRoute>
            } 
          />

          {/* Root Redirect */}
          <Route 
            path="/" 
            element={
              <Navigate to={isAuthenticated ? (userRole === 'Vendor' ? '/vendor-portal' : '/dashboard') : '/login'} replace />
            } 
          />

          {/* Catch-all 404 fallback */}
          <Route 
            path="*" 
            element={
              <Navigate to={isAuthenticated ? (userRole === 'Vendor' ? '/vendor-portal' : '/dashboard') : '/login'} replace />
            } 
          />
        </Routes>
      </main>

      {!isLoginPage && isAuthenticated && (
        <footer className="py-4 text-center text-xs text-slate-500 border-t border-slate-200 bg-white">
          EventCraft AI Management Platform
        </footer>
      )}
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <AppContent />
    </BrowserRouter>
  );
}

export default App;
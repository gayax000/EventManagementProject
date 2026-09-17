import { apiClient } from './api';

export const authService = {
  login: async (email: string, password: string) => {
    try {
      const response = await apiClient.post('/auth/login', { email, password });
      if (response.data && response.data.token) {
        localStorage.setItem('jwt_token', response.data.token);
        localStorage.setItem('user_role', response.data.role || 'Manager');
        const name = response.data.fullName || email.split('@')[0];
        localStorage.setItem('user_name', name);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login error', error);
      return false;
    }
  },

  register: async (fullName: string, email: string, password: string, phoneNumber: string, role: string = 'Vendor') => {
    try {
      const response = await apiClient.post('/auth/register', { fullName, email, password, phoneNumber, role });
      return response.status === 201 || response.status === 200;
    } catch (error) {
      console.error('Register error', error);
      return false;
    }
  },

  logout: () => {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('user_role');
    localStorage.removeItem('user_name');
  },

  getToken: () => {
    return localStorage.getItem('jwt_token');
  },

  getUserName: () => {
    return localStorage.getItem('user_name') || 'User';
  },

  getUserRole: () => {
    return localStorage.getItem('user_role') || 'Customer';
  },

  isLoggedIn: () => {
    return !!localStorage.getItem('jwt_token');
  }
};

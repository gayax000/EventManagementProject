import axios from 'axios';

const isLocalhost = typeof window !== 'undefined' && 
  (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');

let rawUrl = import.meta.env.VITE_API_URL || 
  (isLocalhost ? 'http://localhost:8080/api' : 'https://eventmanagementproject-production-5eee.up.railway.app/api');

rawUrl = rawUrl.trim().replace(/\/+$/, '');
if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
  rawUrl = `https://${rawUrl}`;
}
if (!rawUrl.endsWith('/api')) {
  rawUrl = `${rawUrl}/api`;
}
const API_BASE_URL = rawUrl;

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('jwt_token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export interface EventItem {
  eventId: string;
  title: string;
  eventType?: string;
  targetDate: string;
  guestCount: number;
  budgetLimit: number;
  status: string;
  venueId?: string;
  venueName?: string;
  banquetHallId?: string;
  banquetHallName?: string;
  hallRentalPrice?: number;
  perPlatePrice?: number;
  isOutdoor?: boolean;
  additionalDetails?: string;
  selectedServices?: string[];
  eventSession?: string;
  cateringStyle?: string;
  tableRefreshments?: string[];
  preferredLocation?: string;
  revisionNotes?: string;
  inspirationImages?: string[];
  inspirationImageUrl?: string;
  weatherAssessment?: any;
  estimatedTotalCost?: number;
  assignedVendors?: Array<{ category: string; vendorId?: string; vendorName: string; packageName?: string; packagePrice?: number }>;
  assignedVendorsJson?: string;
  customerId?: string;
  customerName?: string;
  customerEmail?: string;
  customerPhone?: string;
  createdAt: string;
}

export interface BanquetHallItem {
  banquetHallId: string;
  venueId: string;
  venueName: string;
  hallName: string;
  maxCapacity: number;
  hallRentalPrice: number;
  perPlatePrice: number;
  isOutdoor: boolean;
  isAvailable: boolean;
}

export const banquetHallService = {
  getHalls: async (venueId?: string, date?: string): Promise<BanquetHallItem[]> => {
    let url = '/banquethalls';
    const params = new URLSearchParams();
    if (venueId) params.append('venueId', venueId);
    if (date) params.append('date', date);
    if (params.toString()) url += `?${params.toString()}`;
    const response = await apiClient.get<BanquetHallItem[]>(url);
    return response.data;
  },
};

export const eventService = {
  // Fetch events list
  getMyEvents: async (): Promise<EventItem[]> => {
    const response = await apiClient.get<EventItem[]>('/events/my-events');
    return response.data;
  },

  // Manager Approve Proposal with exact finalTotal and optional status & customAddonCost
  approveProposal: async (eventId: string, discount: number = 0, finalTotal?: number, status?: string, customAddonCost?: number, planItems?: string[], assignedVendorsJson?: string) => {
    let url = `/events/${eventId}/approve-proposal?discount=${discount}`;
    if (finalTotal !== undefined) {
      url += `&finalTotal=${finalTotal}`;
    }
    if (status !== undefined) {
      url += `&status=${encodeURIComponent(status)}`;
    }
    if (customAddonCost !== undefined) {
      url += `&customAddonCost=${customAddonCost}`;
    }
    if (assignedVendorsJson) {
      url += `&assignedVendorsJson=${encodeURIComponent(assignedVendorsJson)}`;
    }
    const response = await apiClient.post(url, planItems || null);
    return response.data;
  },

  // Live Synchronize Working Proposal Draft
  syncProposalDraft: async (
    eventId: string,
    payload: {
      finalTotal: number;
      weatherTentCost?: number;
      weatherTentName?: string;
      assignedVendorsJson?: string;
      planItems?: string[];
    }
  ) => {
    const response = await apiClient.put(`/events/${eventId}/sync-draft`, payload);
    return response.data;
  },

  // Get specific event proposal
  getProposal: async (eventId: string) => {
    const response = await apiClient.get(`/events/${eventId}/proposal`);
    return response.data;
  },

  // Create Event Request
  createEvent: async (eventData: Partial<EventItem>) => {
    const response = await apiClient.post('/events', eventData);
    return response.data;
  },

  // Delete Event Request
  deleteEvent: async (eventId: string) => {
    const response = await apiClient.delete(`/events/${eventId}`);
    return response.data;
  },
};

export const venueService = {
  getVenues: async (search?: string) => {
    const url = search ? `/venues?search=${encodeURIComponent(search)}` : '/venues';
    const response = await apiClient.get(url);
    return response.data;
  },
};

export interface VendorItem {
  id?: string;
  vendorId?: string;
  userId?: string;
  name?: string;
  businessName?: string;
  category: string;
  contact?: string;
  contactNumber?: string;
  status?: string;
  verificationStatus?: string;
  adminRemarks?: string;
  packageName?: string;
  packagePrice?: number;
}

export const vendorService = {
  getVendors: async (userId?: string): Promise<VendorItem[]> => {
    const url = userId ? `/venues/vendors?userId=${encodeURIComponent(userId)}` : '/venues/vendors';
    const res = await apiClient.get(url);
    return res.data;
  },
  getMyVendors: async (userId?: string): Promise<VendorItem[]> => {
    const url = userId ? `/venues/vendors/my-vendors?userId=${encodeURIComponent(userId)}` : '/venues/vendors/my-vendors';
    const res = await apiClient.get(url);
    return res.data;
  },
  registerVendor: async (data: { businessName: string; category: string; contactNumber: string; description?: string; packageName?: string; packagePrice?: number; userId?: string }) => {
    const res = await apiClient.post('/venues/vendors/register', data);
    return res.data;
  },
  verifyVendor: async (id: string, status: 'Verified' | 'Rejected', adminRemarks?: string) => {
    const res = await apiClient.put(`/venues/vendors/${id}/verify`, { status, adminRemarks });
    return res.data;
  },
  deleteVendor: async (id: string) => {
    const res = await apiClient.delete(`/venues/vendors/${id}`);
    return res.data;
  },
  getAssignedEvents: async (vendorId?: string, userId?: string) => {
    let url = '/venues/vendors/assigned-events';
    const params = new URLSearchParams();
    if (vendorId) params.append('vendorId', vendorId);
    if (userId) params.append('userId', userId);
    if (params.toString()) url += `?${params.toString()}`;
    const res = await apiClient.get(url);
    return res.data;
  },
  assignVendorsToEvent: async (eventId: string, vendors: Array<{ category: string; vendorId?: string; vendorName: string; packageName?: string; packagePrice?: number }>) => {
    const res = await apiClient.put(`/events/${eventId}/assigned-vendors`, vendors);
    return res.data;
  },
};

export interface LivePaymentItem {
  id: string;
  bookingRef: string;
  clientName: string;
  eventTitle: string;
  amount: number;
  slipUrl: string;
  date: string;
  status: string;
  rejectReason?: string;
  invoiceNumber?: string;
}

export const paymentService = {
  getPayments: async (): Promise<LivePaymentItem[]> => {
    const res = await apiClient.get('/payments');
    return res.data;
  },
  verifyPayment: async (id: string, status: 'Approved' | 'Rejected', rejectReason?: string) => {
    const res = await apiClient.put(`/payments/${id}/verify`, { status, rejectReason });
    return res.data;
  },
  getRevenueForecast: async () => {
    const res = await apiClient.get('/payments/analytics/revenue-forecast');
    return res.data;
  },
};

export interface ManagerNotificationItem {
  notificationId: string;
  userId: string;
  eventId?: string;
  title: string;
  message: string;
  type: string;
  isRead: boolean;
  createdAt: string;
}

export const notificationService = {
  getManagerNotifications: async (): Promise<{ unreadCount: number; notifications: ManagerNotificationItem[] }> => {
    const res = await apiClient.get('/notifications/manager');
    return res.data;
  },
  markAsRead: async (id: string) => {
    const res = await apiClient.post(`/notifications/${id}/mark-read`);
    return res.data;
  },
  markAllAsRead: async () => {
    const res = await apiClient.post('/notifications/mark-all-read');
    return res.data;
  },
};
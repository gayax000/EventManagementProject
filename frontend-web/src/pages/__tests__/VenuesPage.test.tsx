import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { VenuesPage } from '../VenuesPage';
import { venueService } from '../../services/api';

vi.mock('../../services/api', () => ({
  venueService: {
    getVenues: vi.fn(),
  },
  banquetHallService: {
    getHalls: vi.fn(),
  },
}));

// Mock static assets
vi.mock('../../assets/cities/all.png', () => ({ default: 'all.png' }));
vi.mock('../../assets/cities/colombo.png', () => ({ default: 'colombo.png' }));
vi.mock('../../assets/cities/kandy.png', () => ({ default: 'kandy.png' }));
vi.mock('../../assets/cities/nuwara-eliya.png', () => ({ default: 'nuwara-eliya.png' }));
vi.mock('../../assets/cities/bentota.png', () => ({ default: 'bentota.png' }));
vi.mock('../../assets/cities/galle.png', () => ({ default: 'galle.png' }));
vi.mock('../../assets/cities/dambulla.png', () => ({ default: 'dambulla.png' }));
vi.mock('../../assets/cities/negombo.png', () => ({ default: 'negombo.png' }));
vi.mock('../../assets/cities/weligama.png', () => ({ default: 'weligama.png' }));
vi.mock('../../assets/cities/tangalle.png', () => ({ default: 'tangalle.png' }));

describe('VenuesPage Component', () => {
  const sampleVenues = [
    {
      venueId: 'v-1',
      name: 'Shangri-La Colombo',
      locationAddress: '1 Galle Face, Colombo 02',
      maxCapacity: 1200,
      baseRentalPrice: 650000,
      isOutdoor: false,
      isHotel: true,
      imageUrl: 'https://example.com/shangrila.jpg',
    },
    {
      venueId: 'v-2',
      name: 'Earls Regency Kandy',
      locationAddress: 'Tennekumbura, Kandy',
      maxCapacity: 600,
      baseRentalPrice: 400000,
      isOutdoor: true,
      isHotel: true,
      imageUrl: 'https://example.com/earls.jpg',
    },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state initially and then displays venue cards', async () => {
    vi.mocked(venueService.getVenues).mockResolvedValueOnce(sampleVenues);

    render(<VenuesPage />);

    await waitFor(() => {
      expect(venueService.getVenues).toHaveBeenCalled();
      expect(screen.getByText('Shangri-La Colombo')).toBeInTheDocument();
      expect(screen.getByText('Earls Regency Kandy')).toBeInTheDocument();
    });
  });

  it('filters displayed venues when searching', async () => {
    vi.mocked(venueService.getVenues).mockResolvedValue(sampleVenues);

    render(<VenuesPage />);

    await waitFor(() => {
      expect(screen.getByText('Shangri-La Colombo')).toBeInTheDocument();
    });

    const searchInput = screen.getByPlaceholderText(/Search by hotel name or city.../i);
    fireEvent.change(searchInput, { target: { value: 'Shangri' } });

    await waitFor(() => {
      expect(venueService.getVenues).toHaveBeenCalledWith('Shangri');
    });
  });

  it('filters venues by quick city selector', async () => {
    vi.mocked(venueService.getVenues).mockResolvedValue(sampleVenues);

    render(<VenuesPage />);

    await waitFor(() => {
      expect(screen.getByText('Shangri-La Colombo')).toBeInTheDocument();
      expect(screen.getByText('Earls Regency Kandy')).toBeInTheDocument();
    });

    // Select Kandy filter
    const kandyButton = screen.getByRole('button', { name: /Kandy/i });
    fireEvent.click(kandyButton);

    await waitFor(() => {
      expect(screen.getByText('Earls Regency Kandy')).toBeInTheDocument();
      expect(screen.queryByText('Shangri-La Colombo')).not.toBeInTheDocument();
    });
  });

  it('handles empty API result gracefully by displaying No Venues Found', async () => {
    vi.mocked(venueService.getVenues).mockResolvedValueOnce([]);

    render(<VenuesPage />);

    await waitFor(() => {
      expect(screen.getByText(/No Venues Found/i)).toBeInTheDocument();
    });
  });
});

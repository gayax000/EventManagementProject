export interface FallbackBanquetHall {
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

export interface FallbackVenue {
  venueId: string;
  name: string;
  locationAddress: string;
  maxCapacity: number;
  baseRentalPrice: number;
  isOutdoor: boolean;
  halls: FallbackBanquetHall[];
}

export const FALLBACK_VENUES: FallbackVenue[] = [
  // Colombo
  {
    venueId: "v-colombo-1",
    name: "Shangri-La Colombo",
    locationAddress: "1 Galle Face, Colombo 02",
    maxCapacity: 1200,
    baseRentalPrice: 850000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-shangrila-1", venueId: "v-colombo-1", venueName: "Shangri-La Colombo", hallName: "Lotus Grand Ballroom", maxCapacity: 1000, hallRentalPrice: 450000, perPlatePrice: 6500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-shangrila-2", venueId: "v-colombo-1", venueName: "Shangri-La Colombo", hallName: "Sapphire Banquet Hall", maxCapacity: 400, hallRentalPrice: 280000, perPlatePrice: 6000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-shangrila-3", venueId: "v-colombo-1", venueName: "Shangri-La Colombo", hallName: "Sunset Ocean Terrace", maxCapacity: 250, hallRentalPrice: 220000, perPlatePrice: 5500, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-2",
    name: "Cinnamon Grand Colombo",
    locationAddress: "77 Galle Road, Colombo 03",
    maxCapacity: 600,
    baseRentalPrice: 650000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-cingrand-1", venueId: "v-colombo-2", venueName: "Cinnamon Grand Colombo", hallName: "Oak Room Ballroom", maxCapacity: 600, hallRentalPrice: 350000, perPlatePrice: 5500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-cingrand-2", venueId: "v-colombo-2", venueName: "Cinnamon Grand Colombo", hallName: "Cedar Banquet Suite", maxCapacity: 300, hallRentalPrice: 200000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-cingrand-3", venueId: "v-colombo-2", venueName: "Cinnamon Grand Colombo", hallName: "Atrium Garden Terrace", maxCapacity: 350, hallRentalPrice: 250000, perPlatePrice: 5200, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-3",
    name: "Galle Face Hotel",
    locationAddress: "2 Galle Road, Colombo 03",
    maxCapacity: 500,
    baseRentalPrice: 750000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-gfh-1", venueId: "v-colombo-3", venueName: "Galle Face Hotel", hallName: "Grand Ballroom & Jubilee Hall", maxCapacity: 450, hallRentalPrice: 380000, perPlatePrice: 5800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-gfh-2", venueId: "v-colombo-3", venueName: "Galle Face Hotel", hallName: "Chequerboard Lawn by the Sea", maxCapacity: 500, hallRentalPrice: 420000, perPlatePrice: 6000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-4",
    name: "Cinnamon Lakeside",
    locationAddress: "115 Sir Chittampalam A Gardiner Mawatha, Colombo 02",
    maxCapacity: 450,
    baseRentalPrice: 550000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-cinlake-1", venueId: "v-colombo-4", venueName: "Cinnamon Lakeside", hallName: "Kings Court Ballroom", maxCapacity: 450, hallRentalPrice: 320000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-cinlake-2", venueId: "v-colombo-4", venueName: "Cinnamon Lakeside", hallName: "Waterside Garden Lawn", maxCapacity: 350, hallRentalPrice: 280000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-5",
    name: "Hilton Colombo",
    locationAddress: "2 Sir Chittampalam A Gardiner Mawatha, Colombo 02",
    maxCapacity: 700,
    baseRentalPrice: 700000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-hilton-1", venueId: "v-colombo-5", venueName: "Hilton Colombo", hallName: "Grand Ballroom", maxCapacity: 600, hallRentalPrice: 380000, perPlatePrice: 5600, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-hilton-2", venueId: "v-colombo-5", venueName: "Hilton Colombo", hallName: "Poolside Terrace", maxCapacity: 300, hallRentalPrice: 260000, perPlatePrice: 5200, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-6",
    name: "The Kingsbury Colombo",
    locationAddress: "48 Janadhipathi Mawatha, Colombo 01",
    maxCapacity: 400,
    baseRentalPrice: 500000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-kb-1", venueId: "v-colombo-6", venueName: "The Kingsbury Colombo", hallName: "The Balmoral Ballroom", maxCapacity: 350, hallRentalPrice: 300000, perPlatePrice: 5400, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-kb-2", venueId: "v-colombo-6", venueName: "The Kingsbury Colombo", hallName: "The Victorian Hall", maxCapacity: 200, hallRentalPrice: 180000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-7",
    name: "Water's Edge Battaramulla",
    locationAddress: "316 Pannipitiya Road, Battaramulla",
    maxCapacity: 1000,
    baseRentalPrice: 600000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-we-1", venueId: "v-colombo-7", venueName: "Water's Edge Battaramulla", hallName: "Grand Ballroom & Eagle Suite", maxCapacity: 600, hallRentalPrice: 400000, perPlatePrice: 5500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-we-2", venueId: "v-colombo-7", venueName: "Water's Edge Battaramulla", hallName: "The Boardwalk & Lakefront Lawn", maxCapacity: 1000, hallRentalPrice: 450000, perPlatePrice: 5800, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-8",
    name: "Mount Lavinia Hotel",
    locationAddress: "100 Hotel Road, Mount Lavinia",
    maxCapacity: 600,
    baseRentalPrice: 580000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-mlh-1", venueId: "v-colombo-8", venueName: "Mount Lavinia Hotel", hallName: "Empire Ballroom", maxCapacity: 450, hallRentalPrice: 340000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-mlh-2", venueId: "v-colombo-8", venueName: "Mount Lavinia Hotel", hallName: "Sunset Beach Front & Terrace", maxCapacity: 500, hallRentalPrice: 360000, perPlatePrice: 5500, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-9",
    name: "Mövenpick Hotel Colombo",
    locationAddress: "24 Dharmapala Mawatha, Colombo 03",
    maxCapacity: 200,
    baseRentalPrice: 400000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-mov-1", venueId: "v-colombo-9", venueName: "Mövenpick Hotel Colombo", hallName: "Monte Carlo Ballroom", maxCapacity: 180, hallRentalPrice: 240000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-mov-2", venueId: "v-colombo-9", venueName: "Mövenpick Hotel Colombo", hallName: "Rooftop Vistas Deck", maxCapacity: 150, hallRentalPrice: 220000, perPlatePrice: 5400, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-colombo-10",
    name: "Marino Beach Colombo",
    locationAddress: "590 Marine Drive, Colombo 03",
    maxCapacity: 350,
    baseRentalPrice: 450000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-mar-1", venueId: "v-colombo-10", venueName: "Marino Beach Colombo", hallName: "Sky Grand Ballroom", maxCapacity: 350, hallRentalPrice: 320000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-mar-2", venueId: "v-colombo-10", venueName: "Marino Beach Colombo", hallName: "Rooftop Oceanview Deck", maxCapacity: 250, hallRentalPrice: 300000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },

  // Nuwara Eliya
  {
    venueId: "v-ne-1",
    name: "The Grand Hotel Nuwara Eliya",
    locationAddress: "Grand Hotel Road, Nuwara Eliya",
    maxCapacity: 350,
    baseRentalPrice: 450000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-grand-1", venueId: "v-ne-1", venueName: "The Grand Hotel Nuwara Eliya", hallName: "Colonial Grand Ballroom", maxCapacity: 300, hallRentalPrice: 280000, perPlatePrice: 5400, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-grand-2", venueId: "v-ne-1", venueName: "The Grand Hotel Nuwara Eliya", hallName: "English Heritage Garden Lawn", maxCapacity: 350, hallRentalPrice: 320000, perPlatePrice: 5800, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-ne-2",
    name: "Heritance Tea Factory",
    locationAddress: "Kandapola, Nuwara Eliya",
    maxCapacity: 200,
    baseRentalPrice: 380000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-htf-1", venueId: "v-ne-2", venueName: "Heritance Tea Factory", hallName: "Kenmare Dining Hall", maxCapacity: 150, hallRentalPrice: 200000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-htf-2", venueId: "v-ne-2", venueName: "Heritance Tea Factory", hallName: "Misty Tea Plantation Lawn", maxCapacity: 200, hallRentalPrice: 240000, perPlatePrice: 5500, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-ne-3",
    name: "Araliya Green City",
    locationAddress: "Nuwara Eliya Town Center",
    maxCapacity: 400,
    baseRentalPrice: 420000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-agc-1", venueId: "v-ne-3", venueName: "Araliya Green City", hallName: "Royal Grand Ballroom", maxCapacity: 350, hallRentalPrice: 280000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true }
    ]
  },
  {
    venueId: "v-ne-4",
    name: "Jetwing St. Andrew's",
    locationAddress: "St. Andrew's Drive, Nuwara Eliya",
    maxCapacity: 180,
    baseRentalPrice: 320000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-jsa-1", venueId: "v-ne-4", venueName: "Jetwing St. Andrew's", hallName: "Georgian Banquet Room", maxCapacity: 140, hallRentalPrice: 180000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-jsa-2", venueId: "v-ne-4", venueName: "Jetwing St. Andrew's", hallName: "Country Garden Lawn", maxCapacity: 180, hallRentalPrice: 210000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-ne-5",
    name: "Nuwara Eliya Golf Club",
    locationAddress: "Park Road, Nuwara Eliya",
    maxCapacity: 300,
    baseRentalPrice: 350000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-negc-1", venueId: "v-ne-5", venueName: "Nuwara Eliya Golf Club", hallName: "Heritage Golf Clubhouse Hall", maxCapacity: 180, hallRentalPrice: 220000, perPlatePrice: 4500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-negc-2", venueId: "v-ne-5", venueName: "Nuwara Eliya Golf Club", hallName: "Colonial Pine Fairway Lawn", maxCapacity: 300, hallRentalPrice: 280000, perPlatePrice: 4800, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-ne-6",
    name: "Langdale Boutique Hotel",
    locationAddress: "Radella, Nuwara Eliya",
    maxCapacity: 150,
    baseRentalPrice: 280000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-lang-1", venueId: "v-ne-6", venueName: "Langdale Boutique Hotel", hallName: "Radella Valley Banquet Suite", maxCapacity: 120, hallRentalPrice: 160000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-lang-2", venueId: "v-ne-6", venueName: "Langdale Boutique Hotel", hallName: "Pine Vista Hillside Garden", maxCapacity: 150, hallRentalPrice: 190000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },

  // Kandy
  {
    venueId: "v-kandy-1",
    name: "Earl's Regency Kandy",
    locationAddress: "Tennekumbura, Kandy",
    maxCapacity: 700,
    baseRentalPrice: 550000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-earl-1", venueId: "v-kandy-1", venueName: "Earl's Regency Kandy", hallName: "Regency Grand Ballroom", maxCapacity: 600, hallRentalPrice: 360000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-earl-2", venueId: "v-kandy-1", venueName: "Earl's Regency Kandy", hallName: "Riverview Garden Lawn", maxCapacity: 400, hallRentalPrice: 280000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-kandy-2",
    name: "The Grand Kandyan Hotel",
    locationAddress: "89/10 Lady Gordon's Drive, Kandy",
    maxCapacity: 800,
    baseRentalPrice: 600000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-gk-1", venueId: "v-kandy-2", venueName: "The Grand Kandyan Hotel", hallName: "Royal Peacock Ballroom", maxCapacity: 700, hallRentalPrice: 390000, perPlatePrice: 5400, isOutdoor: false, isAvailable: true }
    ]
  },
  {
    venueId: "v-kandy-3",
    name: "Mahaweli Reach Hotel",
    locationAddress: "35 P.B.A. Weerakoon Mawatha, Kandy",
    maxCapacity: 400,
    baseRentalPrice: 480000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-mr-1", venueId: "v-kandy-3", venueName: "Mahaweli Reach Hotel", hallName: "Grand Riverina Ballroom", maxCapacity: 350, hallRentalPrice: 290000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-mr-2", venueId: "v-kandy-3", venueName: "Mahaweli Reach Hotel", hallName: "Riverfront Palm Garden Lawn", maxCapacity: 400, hallRentalPrice: 320000, perPlatePrice: 5200, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-kandy-4",
    name: "Amaya Hills Kandy",
    locationAddress: "Heerassagala, Kandy",
    maxCapacity: 300,
    baseRentalPrice: 400000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-ah-1", venueId: "v-kandy-4", venueName: "Amaya Hills Kandy", hallName: "Kandyan Heritage Ballroom", maxCapacity: 250, hallRentalPrice: 240000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-ah-2", venueId: "v-kandy-4", venueName: "Amaya Hills Kandy", hallName: "Mist Valley Terrace Lawn", maxCapacity: 300, hallRentalPrice: 270000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-kandy-5",
    name: "Cinnamon Citadel Kandy",
    locationAddress: "124 Srimath Kuda Ratwatte Mawatha, Kandy",
    maxCapacity: 250,
    baseRentalPrice: 380000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-cc-1", venueId: "v-kandy-5", venueName: "Cinnamon Citadel Kandy", hallName: "Citadel Riverside Ballroom", maxCapacity: 200, hallRentalPrice: 220000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-cc-2", venueId: "v-kandy-5", venueName: "Cinnamon Citadel Kandy", hallName: "Mahaweli Riverbank Terrace", maxCapacity: 250, hallRentalPrice: 250000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },

  // Down South (Galle, Bentota, Weligama, Tangalle)
  {
    venueId: "v-galle-1",
    name: "Jetwing Lighthouse Galle",
    locationAddress: "Dadella, Galle",
    maxCapacity: 450,
    baseRentalPrice: 620000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-jl-1", venueId: "v-galle-1", venueName: "Jetwing Lighthouse Galle", hallName: "Lighthouse Grand Ballroom", maxCapacity: 300, hallRentalPrice: 380000, perPlatePrice: 5500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-jl-2", venueId: "v-galle-1", venueName: "Jetwing Lighthouse Galle", hallName: "Oceanfront Rocks Lawn", maxCapacity: 450, hallRentalPrice: 420000, perPlatePrice: 5800, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-galle-2",
    name: "Heritance Ahungalla",
    locationAddress: "Galle Road, Ahungalla",
    maxCapacity: 500,
    baseRentalPrice: 550000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-ha-1", venueId: "v-galle-2", venueName: "Heritance Ahungalla", hallName: "Ahungalla Grand Ballroom", maxCapacity: 400, hallRentalPrice: 330000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-ha-2", venueId: "v-galle-2", venueName: "Heritance Ahungalla", hallName: "Ocean Coconut Grove Lawn", maxCapacity: 500, hallRentalPrice: 370000, perPlatePrice: 5400, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-bentota-1",
    name: "Cinnamon Bentota Beach",
    locationAddress: "Bentota Coastal Strip",
    maxCapacity: 600,
    baseRentalPrice: 680000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-cbb-1", venueId: "v-bentota-1", venueName: "Cinnamon Bentota Beach", hallName: "Bawa Heritage Ballroom", maxCapacity: 450, hallRentalPrice: 420000, perPlatePrice: 5800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-cbb-2", venueId: "v-bentota-1", venueName: "Cinnamon Bentota Beach", hallName: "Lagoon & Ocean Sandy Lawn", maxCapacity: 600, hallRentalPrice: 460000, perPlatePrice: 6000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-weligama-1",
    name: "Weligama Bay Marriott Resort",
    locationAddress: "700 Matara Road, Weligama",
    maxCapacity: 550,
    baseRentalPrice: 720000,
    isOutdoor: false,
    halls: [
      { banquetHallId: "h-wbm-1", venueId: "v-weligama-1", venueName: "Weligama Bay Marriott Resort", hallName: "Pearl Grand Ballroom", maxCapacity: 550, hallRentalPrice: 480000, perPlatePrice: 6200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-wbm-2", venueId: "v-weligama-1", venueName: "Weligama Bay Marriott Resort", hallName: "Sunset Oceanfront Lawn", maxCapacity: 400, hallRentalPrice: 450000, perPlatePrice: 6000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-galle-3",
    name: "The Fortress Resort & Spa",
    locationAddress: "Koggala, Galle",
    maxCapacity: 250,
    baseRentalPrice: 520000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-fort-1", venueId: "v-galle-3", venueName: "The Fortress Resort & Spa", hallName: "White Ballroom", maxCapacity: 180, hallRentalPrice: 280000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-fort-2", venueId: "v-galle-3", venueName: "The Fortress Resort & Spa", hallName: "Cliffside Ocean Palm Lawn", maxCapacity: 250, hallRentalPrice: 320000, perPlatePrice: 5500, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-tangalle-1",
    name: "Anantara Peace Haven Tangalle",
    locationAddress: "Goyambokka Estate, Tangalle",
    maxCapacity: 300,
    baseRentalPrice: 750000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-apt-1", venueId: "v-tangalle-1", venueName: "Anantara Peace Haven Tangalle", hallName: "Peace Haven Grand Ballroom", maxCapacity: 220, hallRentalPrice: 420000, perPlatePrice: 6000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-apt-2", venueId: "v-tangalle-1", venueName: "Anantara Peace Haven Tangalle", hallName: "Cliffside Ocean Lawn", maxCapacity: 300, hallRentalPrice: 460000, perPlatePrice: 6400, isOutdoor: true, isAvailable: true }
    ]
  },

  // Cultural Triangle / Dambulla / Sigiriya
  {
    venueId: "v-dambulla-1",
    name: "Heritance Kandalama",
    locationAddress: "Kandalama, Dambulla",
    maxCapacity: 350,
    baseRentalPrice: 580000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-hk-1", venueId: "v-dambulla-1", venueName: "Heritance Kandalama", hallName: "Kashyapa Grand Ballroom", maxCapacity: 300, hallRentalPrice: 340000, perPlatePrice: 5400, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-hk-2", venueId: "v-dambulla-1", venueName: "Heritance Kandalama", hallName: "Rock Cliff Garden Lawn", maxCapacity: 350, hallRentalPrice: 380000, perPlatePrice: 5600, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-dambulla-2",
    name: "Cinnamon Lodge Habarana",
    locationAddress: "Habarana",
    maxCapacity: 400,
    baseRentalPrice: 460000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-clh-1", venueId: "v-dambulla-2", venueName: "Cinnamon Lodge Habarana", hallName: "Habarana Banquet Hall", maxCapacity: 320, hallRentalPrice: 280000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-clh-2", venueId: "v-dambulla-2", venueName: "Cinnamon Lodge Habarana", hallName: "Lakeside Wilderness Lawn", maxCapacity: 400, hallRentalPrice: 310000, perPlatePrice: 5200, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-dambulla-3",
    name: "Jetwing Lake Dambulla",
    locationAddress: "Mirisgonioya, Dambulla",
    maxCapacity: 300,
    baseRentalPrice: 420000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-jld-1", venueId: "v-dambulla-3", venueName: "Jetwing Lake Dambulla", hallName: "Siyambala Ballroom", maxCapacity: 250, hallRentalPrice: 260000, perPlatePrice: 4900, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-jld-2", venueId: "v-dambulla-3", venueName: "Jetwing Lake Dambulla", hallName: "Lakefront Panorama Lawn", maxCapacity: 300, hallRentalPrice: 290000, perPlatePrice: 5100, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-dambulla-4",
    name: "Aliya Resort & Spa",
    locationAddress: "Audangawa, Sigiriya",
    maxCapacity: 450,
    baseRentalPrice: 500000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-aliya-1", venueId: "v-dambulla-4", venueName: "Aliya Resort & Spa", hallName: "Audangawa Banquet Suite", maxCapacity: 250, hallRentalPrice: 280000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-aliya-2", venueId: "v-dambulla-4", venueName: "Aliya Resort & Spa", hallName: "Sigiriya Rock View Garden Lawn", maxCapacity: 450, hallRentalPrice: 350000, perPlatePrice: 5200, isOutdoor: true, isAvailable: true }
    ]
  },

  // Negombo
  {
    venueId: "v-negombo-1",
    name: "Heritance Negombo",
    locationAddress: "Lewis Place, Negombo",
    maxCapacity: 500,
    baseRentalPrice: 540000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-hn-1", venueId: "v-negombo-1", venueName: "Heritance Negombo", hallName: "Lagoon View Ballroom", maxCapacity: 400, hallRentalPrice: 320000, perPlatePrice: 5200, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-hn-2", venueId: "v-negombo-1", venueName: "Heritance Negombo", hallName: "Golden Sand Coastal Lawn", maxCapacity: 500, hallRentalPrice: 360000, perPlatePrice: 5500, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-negombo-2",
    name: "Jetwing Blue Negombo",
    locationAddress: "Ethukale, Negombo",
    maxCapacity: 400,
    baseRentalPrice: 480000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-jb-1", venueId: "v-negombo-2", venueName: "Jetwing Blue Negombo", hallName: "Azure Ballroom", maxCapacity: 350, hallRentalPrice: 290000, perPlatePrice: 5000, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-jb-2", venueId: "v-negombo-2", venueName: "Jetwing Blue Negombo", hallName: "Tropical Sunset Beach Deck", maxCapacity: 400, hallRentalPrice: 320000, perPlatePrice: 5300, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-negombo-3",
    name: "Club Hotel Dolphin",
    locationAddress: "Waikkal, Negombo",
    maxCapacity: 600,
    baseRentalPrice: 520000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-chd-1", venueId: "v-negombo-3", venueName: "Club Hotel Dolphin", hallName: "Dolphin Island Ballroom", maxCapacity: 450, hallRentalPrice: 310000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-chd-2", venueId: "v-negombo-3", venueName: "Club Hotel Dolphin", hallName: "Seaside Palm Oasis Lawn", maxCapacity: 600, hallRentalPrice: 350000, perPlatePrice: 5100, isOutdoor: true, isAvailable: true }
    ]
  },

  // Other Regions
  {
    venueId: "v-trinco-1",
    name: "Trinqua Blu by Cinnamon",
    locationAddress: "Sampalthivu Post, Trincomalee",
    maxCapacity: 350,
    baseRentalPrice: 440000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-trinco-1", venueId: "v-trinco-1", venueName: "Trinqua Blu by Cinnamon", hallName: "Blu Cove Ballroom", maxCapacity: 280, hallRentalPrice: 260000, perPlatePrice: 4800, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-trinco-2", venueId: "v-trinco-1", venueName: "Trinqua Blu by Cinnamon", hallName: "East Coast Beachfront Terrace", maxCapacity: 350, hallRentalPrice: 290000, perPlatePrice: 5000, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-jaffna-1",
    name: "Jetwing Jaffna",
    locationAddress: "37 Mahatma Gandhi Road, Jaffna",
    maxCapacity: 200,
    baseRentalPrice: 320000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-jj-1", venueId: "v-jaffna-1", venueName: "Jetwing Jaffna", hallName: "Nallur Cultural Ballroom", maxCapacity: 160, hallRentalPrice: 190000, perPlatePrice: 4500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-jj-2", venueId: "v-jaffna-1", venueName: "Jetwing Jaffna", hallName: "Palmyrah Sky Terrace", maxCapacity: 200, hallRentalPrice: 220000, perPlatePrice: 4800, isOutdoor: true, isAvailable: true }
    ]
  },
  {
    venueId: "v-passikudah-1",
    name: "Uga Bay Passikudah",
    locationAddress: "Passikudah Bay, Kalkudah",
    maxCapacity: 300,
    baseRentalPrice: 560000,
    isOutdoor: true,
    halls: [
      { banquetHallId: "h-uga-1", venueId: "v-passikudah-1", venueName: "Uga Bay Passikudah", hallName: "Calm Waters Banquet Suite", maxCapacity: 220, hallRentalPrice: 320000, perPlatePrice: 5500, isOutdoor: false, isAvailable: true },
      { banquetHallId: "h-uga-2", venueId: "v-passikudah-1", venueName: "Uga Bay Passikudah", hallName: "Golden Coral Bay Lawn", maxCapacity: 300, hallRentalPrice: 360000, perPlatePrice: 5800, isOutdoor: true, isAvailable: true }
    ]
  }
];

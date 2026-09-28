import React, { useState, useEffect } from 'react';
import { 
  Building2, 
  ShieldCheck, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Phone, 
  Sparkles, 
  PlusCircle,
  Layers,
  AlertCircle,
  Tag,
  ChevronRight,
  TrendingUp,
  Cpu
} from 'lucide-react';
import { vendorService, type VendorItem } from '../services/api';
import { authService } from '../services/authService';

export interface ServiceTierOption {
  tier: string;
  name: string;
  label: string;
  price: number;
  description: string;
}

export const CATEGORY_TIERS_MAP: Record<string, ServiceTierOption[]> = {
  Photography: [
    { tier: 'Tier 1 (Budget)', name: 'Single Photographer, Soft Copies & Color Graded', label: 'Tier 1: Solo Photographer & Soft Copies', price: 45000, description: 'Solo professional photographer covering the ceremony. Unlimited high-res color-graded digital soft copies delivered within 7 days.' },
    { tier: 'Tier 2 (Mid-Range)', name: '2 Photographers, Full Day Coverage & Storybook Highlights', label: 'Tier 2: 2 Photographers & Storybook Album', price: 95000, description: '2 Senior Photographers with full-day coverage. Includes 30-page magazine storybook album, thank you cards, and edited digital copies.' },
    { tier: 'Tier 3 (Premium)', name: 'Master 4K Video, 2 Photographers & Storybook Wedding Album', label: 'Tier 3: Master 4K Video + 2 Photographers & Album', price: 160000, description: 'Master wedding coverage with 2 Senior Photographers and 4K Cinematographer. Includes 40-page luxury acrylic crystal album & 4K teaser.' },
    { tier: 'Tier 4 (Luxury)', name: 'Royal Cinematic Rig, 4K Drone & 3 Senior Photographers', label: 'Tier 4: Royal Cinema Rig, Drone & 3 Photographers', price: 250000, description: 'Elite wedding coverage with cinema-grade Sony FX rigs, licensed drone pilot, 3 Senior Photographers, 2 Cinematographers & two 50-page albums.' }
  ],
  SoundLighting: [
    { tier: 'Tier 1 (Budget)', name: 'Compact Speech PA Kit + 2 Wireless Mics', label: 'Tier 1: Compact Speech PA Kit + 2 Mics', price: 40000, description: 'Compact Speech PA Kit with 2 wireless mics and Bluetooth hub for intimate gatherings.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Standard Stage Audio + Warm Ambient LED PAR Cans', label: 'Tier 2: Standard Stage Audio + Ambient LED', price: 85000, description: 'Standard stage sound, 8 warm LED ambient uplights, dual wireless mics and digital mixer.' },
    { tier: 'Tier 3 (Premium)', name: 'Concert Line-Array Sound & Digital Mixer Package', label: 'Tier 3: Line-Array Sound & Digital Mixer', price: 180000, description: 'High-power concert line-array sound rig with digital audio console and live mixing.' },
    { tier: 'Tier 4 (Luxury)', name: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses', label: 'Tier 4: Concert Line-Array + 16 Moving Heads', price: 250000, description: 'Concert line-array rig with 16 intelligent moving heads, beam trusses, atmospheric hazers.' }
  ],
  AudioVisual: [
    { tier: 'Tier 1 (Budget)', name: 'Compact Speech PA Kit + 2 Wireless Mics', label: 'Tier 1: Compact Speech PA Kit + 2 Mics', price: 40000, description: 'Compact Speech PA Kit with 2 wireless mics and Bluetooth hub.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Standard Stage Audio + Warm Ambient LED PAR Cans', label: 'Tier 2: Standard Stage Audio + Ambient LED', price: 85000, description: 'Standard stage audio and warm mood uplights.' },
    { tier: 'Tier 3 (Premium)', name: 'Concert Line-Array Sound & Digital Mixer Package', label: 'Tier 3: Line-Array Sound & Digital Mixer', price: 180000, description: 'Concert line-array sound & digital audio console.' },
    { tier: 'Tier 4 (Luxury)', name: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses', label: 'Tier 4: Concert Line-Array + 16 Moving Heads', price: 250000, description: 'Concert line-array rig + 16 moving heads & trusses.' }
  ],
  Decor: [
    { tier: 'Tier 1 (Budget)', name: 'Minimalist Floral Arch + Cake Table Styling', label: 'Tier 1: Minimalist Floral Arch & Cake Table', price: 45000, description: 'Minimalist floral arch, Poruwa styling and cake table decor.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Thematic Floral Stage + Table Centerpieces', label: 'Tier 2: Thematic Floral Stage & Centerpieces', price: 85000, description: 'Thematic floral stage backdrop, entrance arch, and fresh floral guest table centerpieces.' },
    { tier: 'Tier 3 (Premium)', name: 'Thematic Floral Stage + Entrance Tunnel Arch', label: 'Tier 3: Floral Stage + Entrance Tunnel Arch', price: 140000, description: 'Thematic floral stage, entrance tunnel arch, settee backdrop, and table centerpieces.' },
    { tier: 'Tier 4 (Luxury)', name: 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor', label: 'Tier 4: Royal Fresh Flower Drapes & Grand Stage', price: 220000, description: 'Grand stage decor with imported fresh flowers, draped floral ceiling, and starry light wall.' }
  ],
  Transport: [
    { tier: 'Tier 1 (Budget)', name: 'Toyota Premio / Allion Executive Chauffeur Sedan', label: 'Tier 1: Executive Chauffeur Sedan', price: 35000, description: 'Comfortable air-conditioned executive chauffeur sedan for couple and VIP transfers.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'BMW 5-Series Executive Bridal Sedan', label: 'Tier 2: BMW 5-Series Executive Sedan', price: 50000, description: 'Luxury BMW 5-Series executive bridal sedan with professional suited chauffeur.' },
    { tier: 'Tier 3 (Premium)', name: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan', label: 'Tier 3: Mercedes-Benz S-Class Luxury Sedan', price: 65000, description: 'Flagship Mercedes-Benz S-Class luxury sedan with dedicated chauffeur and bridal escort.' },
    { tier: 'Tier 4 (Luxury)', name: 'Classic Vintage Rolls Royce / 1954 Jaguar Mark VII', label: 'Tier 4: Classic Vintage Rolls Royce / Jaguar', price: 95000, description: 'Chauffeured classic vintage 1954 Rolls Royce or Jaguar Mark VII with red carpet arrival.' }
  ],
  VIPTransport: [
    { tier: 'Tier 1 (Budget)', name: 'Toyota Premio / Allion Executive Chauffeur Sedan', label: 'Tier 1: Executive Chauffeur Sedan', price: 35000, description: 'Comfortable executive sedan.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'BMW 5-Series Executive Bridal Sedan', label: 'Tier 2: BMW 5-Series Executive Sedan', price: 50000, description: 'BMW 5-Series executive bridal sedan.' },
    { tier: 'Tier 3 (Premium)', name: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan', label: 'Tier 3: Mercedes-Benz S-Class Luxury Sedan', price: 65000, description: 'Mercedes-Benz S-Class luxury sedan.' },
    { tier: 'Tier 4 (Luxury)', name: 'Classic Vintage Rolls Royce / 1954 Jaguar Mark VII', label: 'Tier 4: Classic Vintage Rolls Royce / Jaguar', price: 95000, description: 'Vintage Rolls Royce / Jaguar Mark VII bridal car.' }
  ],
  Cake: [
    { tier: 'Tier 1 (Budget)', name: '2-Tier Classic Buttercream Celebration Cake', label: 'Tier 1: 2-Tier Classic Celebration Cake', price: 15000, description: '2-Tier handcrafted celebration cake in vanilla, chocolate, or ribbon cake.' },
    { tier: 'Tier 2 (Mid-Range)', name: '2-Tier Custom Handcrafted Fondant Cake', label: 'Tier 2: 2-Tier Custom Fondant Cake', price: 30000, description: '2-Tier custom themed handcrafted fondant cake with delicate sugar craft.' },
    { tier: 'Tier 3 (Premium)', name: '3-Tier Luxury Floral Wedding Cake', label: 'Tier 3: 3-Tier Luxury Floral Wedding Cake', price: 45000, description: '3-Tier luxury floral handcrafted wedding cake with handcrafted edible sugar roses.' },
    { tier: 'Tier 4 (Luxury)', name: '5-Tier Royal Handcrafted Fondant Wedding Cake', label: 'Tier 4: 5-Tier Royal Handcrafted Fondant Cake', price: 65000, description: '5-Tier royal centerpiece wedding cake with 24k edible gold leaf and sugar floral cascade.' }
  ],
  Cakes: [
    { tier: 'Tier 1 (Budget)', name: '2-Tier Classic Buttercream Celebration Cake', label: 'Tier 1: 2-Tier Classic Celebration Cake', price: 15000, description: '2-Tier handcrafted celebration cake.' },
    { tier: 'Tier 2 (Mid-Range)', name: '2-Tier Custom Handcrafted Fondant Cake', label: 'Tier 2: 2-Tier Custom Fondant Cake', price: 30000, description: '2-Tier custom themed fondant cake.' },
    { tier: 'Tier 3 (Premium)', name: '3-Tier Luxury Floral Wedding Cake', label: 'Tier 3: 3-Tier Luxury Floral Wedding Cake', price: 45000, description: '3-Tier luxury floral wedding cake.' },
    { tier: 'Tier 4 (Luxury)', name: '5-Tier Royal Handcrafted Fondant Wedding Cake', label: 'Tier 4: 5-Tier Royal Handcrafted Fondant Cake', price: 65000, description: '5-Tier royal handcrafted fondant cake.' }
  ],
  Catering: [
    { tier: 'Tier 1 (Budget)', name: 'Authentic Sri Lankan Traditional Feast', label: 'Tier 1: Sri Lankan Traditional Feast (Rs. 3.8k/plate)', price: 3800, description: 'Claypot traditional buffet: 2 meats (Chicken/Fish), dhal, tempered potatoes, 4 salads, 4 desserts.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Classic Asian & Sri Lankan Fusion Buffet', label: 'Tier 2: Asian & Sri Lankan Fusion (Rs. 5k/plate)', price: 5000, description: 'International fusion buffet: 2 meats, pasta live station, seafood fried rice, 6 desserts.' },
    { tier: 'Tier 3 (Premium)', name: 'Executive 5-Course Carvery & Seafood Buffet', label: 'Tier 3: Executive Carvery & Seafood (Rs. 6.8k/plate)', price: 6800, description: 'Executive buffet: roast carvery, seafood platter, 3 meats, live action station, 8 desserts.' },
    { tier: 'Tier 4 (Luxury)', name: 'Royal 7-Course International Gala Buffet', label: 'Tier 4: Royal 7-Course Gala Buffet (Rs. 8.5k/plate)', price: 8500, description: '7-Course luxury gala: jumbo prawns, lamb carvery, gourmet cheese counter, French pastries.' }
  ],
  CateringPackage: [
    { tier: 'Tier 1 (Budget)', name: 'Authentic Sri Lankan Traditional Feast', label: 'Tier 1: Sri Lankan Traditional Feast (Rs. 3.8k/plate)', price: 3800, description: 'Claypot traditional buffet (Rs. 3,800 per plate).' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Classic Asian & Sri Lankan Fusion Buffet', label: 'Tier 2: Asian & Sri Lankan Fusion (Rs. 5k/plate)', price: 5000, description: 'Fusion buffet with live station (Rs. 5,000 per plate).' },
    { tier: 'Tier 3 (Premium)', name: 'Executive 5-Course Carvery & Seafood Buffet', label: 'Tier 3: Executive Carvery & Seafood (Rs. 6.8k/plate)', price: 6800, description: 'Executive carvery & seafood buffet (Rs. 6,800 per plate).' },
    { tier: 'Tier 4 (Luxury)', name: 'Royal 7-Course International Gala Buffet', label: 'Tier 4: Royal 7-Course Gala Buffet (Rs. 8.5k/plate)', price: 8500, description: 'Royal 7-course international gala buffet (Rs. 8,500 per plate).' }
  ],
  Refreshments: [
    { tier: 'Tier 1 (Budget)', name: 'Traditional Ceylon Ginger Tea, Coffee & Short Eats', label: 'Tier 1: Ceylon Tea & Short Eats (Rs. 250/head)', price: 250, description: 'Traditional Ceylon milk tea, ginger tea, fresh brewed coffee and vegetable/fish rolls.' },
    { tier: 'Tier 2 (Mid-Range)', name: 'Tropical Fresh Fruit Juices & Chilled Mocktail Bar', label: 'Tier 2: Fresh Juice & Mocktail Bar (Rs. 500/head)', price: 500, description: 'Fresh tropical fruit juice station, mint lime coolers, and non-alcoholic mojito bar.' },
    { tier: 'Tier 3 (Premium)', name: 'Artisanal Ceylon Tea & Italian Espresso Barista Lounge', label: 'Tier 3: Espresso Barista Lounge (Rs. 800/head)', price: 800, description: 'Mobile espresso barista lounge, single-origin Ceylon teas, and French canapé platters.' },
    { tier: 'Tier 4 (Action Station)', name: 'Live Midnight Street Food Station (Kottu & Rotti)', label: 'Tier 4: Live Midnight Kottu & Food Bar (Rs. 950/head)', price: 950, description: 'Midnight live action station: chicken cheese kottu, egg hoppers, and mini gourmet sliders.' }
  ],
  MarqueeTent: [
    { tier: 'Tier 1 (Budget)', name: 'Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)', label: 'Tier 1: Pagoda Rain Canopy (15x15 ft)', price: 45000, description: 'Waterproof white pagoda / canopy tent for food stations, bars, or weather shelter.' },
    { tier: 'Tier 2 (Standard)', name: 'Black Weatherproof Heavy-Duty Canopy Tent (20x20 ft)', label: 'Tier 2: Heavy-Duty Canopy (20x20 ft)', price: 80000, description: 'Heavy-duty weatherproof canopy tent with side curtains and ground anchoring.' },
    { tier: 'Tier 3 (Heavy Duty)', name: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)', label: 'Tier 3: Waterproof Marquee Tent (20x40 ft)', price: 150000, description: 'Engineered waterproof marquee tent for large outdoor lawns with complete rain shielding.' },
    { tier: 'Tier 4 (Royal)', name: 'Royal Clear-Roof Transparent Luxury Marquee Tent (40x60 ft)', label: 'Tier 4: Clear-Roof Luxury Marquee Tent', price: 220000, description: 'Clear-roof transparent marquee with fairy lights, chandelier mounts, and AC compatibility.' }
  ],
  PowerBackup: [
    { tier: 'Tier 1 (Budget)', name: 'Portable 15 kVA Diesel Generator Kit', label: 'Tier 1: Portable 15 kVA Generator', price: 35000, description: 'Portable diesel generator suitable for essential lighting and small audio setups.' },
    { tier: 'Tier 2 (Standard)', name: 'Mid-Range 35 kVA Soundproof Outdoor Generator', label: 'Tier 2: 35 kVA Soundproof Generator', price: 60000, description: 'Soundproof outdoor generator with distribution box and on-site technician.' },
    { tier: 'Tier 3 (Heavy Duty)', name: 'Backup Diesel Silent Generator (60 kVA Heavy Duty)', label: 'Tier 3: 60 kVA Silent Heavy Generator', price: 90000, description: '60 kVA silent diesel generator for uninterrupted event power, lighting rigs and kitchens.' },
    { tier: 'Tier 4 (Industrial)', name: 'Industrial 100 kVA Synchronized Silent Dual Generator', label: 'Tier 4: 100 kVA Dual Synchronized Generator', price: 160000, description: '100 kVA synchronized dual generator with automatic changeover switch (ATS).' }
  ]
};

export const VENDOR_SERVICE_CONFIG: Record<string, {
  label: string;
  shortLabel: string;
  icon: string;
  defaultPackage: string;
  defaultPrice: number;
  placeholderName: string;
  placeholderDescription: string;
  tierSample: string;
}> = {
  SoundLighting: {
    label: 'AudioVisual & Stage Lighting',
    shortLabel: 'Sound & Lighting',
    icon: '🔊',
    defaultPackage: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses',
    defaultPrice: 180000,
    placeholderName: 'e.g. Lumina Pro Audio & Stage Lighting',
    placeholderDescription: 'Describe your line-array sound systems, digital audio consoles, intelligent moving heads, beam trusses, and ambient stage lighting...',
    tierSample: 'Line-Array Rig, Moving Heads & Beam Trusses'
  },
  AudioVisual: {
    label: 'AudioVisual & Stage Lighting',
    shortLabel: 'Sound & Lighting',
    icon: '🔊',
    defaultPackage: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses',
    defaultPrice: 180000,
    placeholderName: 'e.g. Lumina Pro Audio & Stage Lighting',
    placeholderDescription: 'Describe your line-array sound systems, digital audio consoles, intelligent moving heads, beam trusses, and ambient stage lighting...',
    tierSample: 'Line-Array Rig, Moving Heads & Beam Trusses'
  },
  Decor: {
    label: 'Floral & Event Decoration',
    shortLabel: 'Decor & Stage',
    icon: '🌸',
    defaultPackage: 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor',
    defaultPrice: 80000,
    placeholderName: 'e.g. Royal Blooms Floral & Stage Design',
    placeholderDescription: 'Describe your bespoke floral arches, stage backdrops, ambient tablescapes, theme styling, and entrance decor...',
    tierSample: 'Floral Drapes, Thematic Stage & Archway Design'
  },
  Photography: {
    label: 'In-House Photography & Cinematography',
    shortLabel: 'Photography',
    icon: '📸',
    defaultPackage: 'Master Wedding Photography + 4K Highlights Video + Storybook Album',
    defaultPrice: 100000,
    placeholderName: 'e.g. Studio Lumiere Wedding & Event Photography',
    placeholderDescription: 'Describe your 4K cinema cameras, aerial drone footage, photography team size, album printing options, and turnaround time...',
    tierSample: '4K Cinema Video, Drone & Storybook Leather Album'
  },
  Cake: {
    label: 'Celebration Cakes & Dessert Art',
    shortLabel: 'Cakes',
    icon: '🎂',
    defaultPackage: '3-Tier Luxury Handcrafted Fondant Floral Wedding Cake',
    defaultPrice: 35000,
    placeholderName: 'e.g. Velvet Crumb Artisan Cake Studio',
    placeholderDescription: 'Describe your handcrafted tiered wedding cakes, flavor profiles, custom fondant sugar flowers, and dessert table spreads...',
    tierSample: '3-5 Tier Fondant Cake, Custom Theme & Dessert Art'
  },
  Cakes: {
    label: 'Celebration Cakes & Dessert Art',
    shortLabel: 'Cakes',
    icon: '🎂',
    defaultPackage: '3-Tier Luxury Handcrafted Fondant Floral Wedding Cake',
    defaultPrice: 35000,
    placeholderName: 'e.g. Velvet Crumb Artisan Cake Studio',
    placeholderDescription: 'Describe your handcrafted tiered wedding cakes, flavor profiles, custom fondant sugar flowers, and dessert table spreads...',
    tierSample: '3-5 Tier Fondant Cake, Custom Theme & Dessert Art'
  },
  Transport: {
    label: 'Luxury Bridal & VIP Transport',
    shortLabel: 'VIP Transport',
    icon: '🚗',
    defaultPackage: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan',
    defaultPrice: 50000,
    placeholderName: 'e.g. Royal Crown VIP & Bridal Chauffeurs',
    placeholderDescription: 'Describe your fleet of luxury sedans (Mercedes, BMW), vintage Rolls Royce/Jaguar bridal cars, 14-seater VIP vans, and chauffeur service...',
    tierSample: 'Vintage Rolls Royce, Mercedes S-Class & VIP Vans'
  },
  VIPTransport: {
    label: 'Luxury Bridal & VIP Transport',
    shortLabel: 'VIP Transport',
    icon: '🚗',
    defaultPackage: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan',
    defaultPrice: 50000,
    placeholderName: 'e.g. Royal Crown VIP & Bridal Chauffeurs',
    placeholderDescription: 'Describe your fleet of luxury sedans (Mercedes, BMW), vintage Rolls Royce/Jaguar bridal cars, 14-seater VIP vans, and chauffeur service...',
    tierSample: 'Vintage Rolls Royce, Mercedes S-Class & VIP Vans'
  },
  Catering: {
    label: 'Catering & Gourmet Buffets',
    shortLabel: 'Catering Buffets',
    icon: '🍽️',
    defaultPackage: '5-Course Royal Gala Dinner Buffet (Per Plate)',
    defaultPrice: 5500,
    placeholderName: 'e.g. Ceylon Grand Banquet Caterers',
    placeholderDescription: 'Describe your buffet menu specialties, live action stations, food hygiene certification, and per-plate packages...',
    tierSample: 'Royal 5-7 Course International Gala Buffets'
  },
  CateringPackage: {
    label: 'Catering & Gourmet Buffets',
    shortLabel: 'Catering Buffets',
    icon: '🍽️',
    defaultPackage: '5-Course Royal Gala Dinner Buffet (Per Plate)',
    defaultPrice: 5500,
    placeholderName: 'e.g. Ceylon Grand Banquet Caterers',
    placeholderDescription: 'Describe your buffet menu specialties, live action stations, food hygiene certification, and per-plate packages...',
    tierSample: 'Royal 5-7 Course International Gala Buffets'
  },
  MarqueeTent: {
    label: 'Marquee & Outdoor Weather Proofing',
    shortLabel: 'Tents & Safeguards',
    icon: '🎪',
    defaultPackage: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)',
    defaultPrice: 150000,
    placeholderName: 'e.g. Ceylon WeatherShield Marquee Tents',
    placeholderDescription: 'Describe your clear-roof marquee tents, waterproof pagoda canopies, rain guttering, wind resistance ratings, and setup crew...',
    tierSample: 'Clear-Roof Transparent Marquee & Pagoda Sets'
  },
  PowerBackup: {
    label: 'Power Backup & Industrial Generators',
    shortLabel: 'Power Backup',
    icon: '⚡',
    defaultPackage: 'Backup Diesel Silent Generator (60 kVA Heavy Duty)',
    defaultPrice: 90000,
    placeholderName: 'e.g. VoltMax Heavy Power & Generator Hire',
    placeholderDescription: 'Describe your soundproof diesel generators (15-100 kVA), automatic transfer switches (ATS), power distribution boards, and on-site technician...',
    tierSample: 'Silent Soundproof Diesel Dual 35-100 kVA Units'
  },
  Refreshments: {
    label: 'Welcome Drinks & Refreshments',
    shortLabel: 'Refreshments',
    icon: '☕',
    defaultPackage: 'Tropical Fresh Fruit Juices & Chilled Mocktail Bar',
    defaultPrice: 500,
    placeholderName: 'e.g. Ceylon Brews & Artisan Mocktails',
    placeholderDescription: 'Describe your Ceylon tea/coffee stations, fresh juice bars, mocktails, and live street food refreshment services...',
    tierSample: 'Espresso Bar, Tropical Mocktails & Ceylon Teas'
  }
};

export const getCategoryInfo = (catKey?: string) => {
  if (!catKey) {
    return { 
      label: 'General Vendor Service', 
      shortLabel: 'Service', 
      icon: '🏪', 
      defaultPackage: 'Standard Service Package', 
      defaultPrice: 5000, 
      placeholderName: 'e.g. Event Service Provider', 
      placeholderDescription: 'Describe your services...',
      tierSample: 'General Event Equipment & Service'
    };
  }
  
  const normalized = catKey.trim().toLowerCase();
  if (normalized.includes('photo')) return VENDOR_SERVICE_CONFIG.Photography;
  if (normalized.includes('cake')) return VENDOR_SERVICE_CONFIG.Cake;
  if (normalized.includes('transport') || normalized.includes('car') || normalized.includes('vehicle') || normalized.includes('vip')) return VENDOR_SERVICE_CONFIG.Transport;
  if (normalized.includes('sound') || normalized.includes('audio') || normalized.includes('light')) return VENDOR_SERVICE_CONFIG.SoundLighting;
  if (normalized.includes('cater') || normalized.includes('food') || normalized.includes('buffet')) return VENDOR_SERVICE_CONFIG.Catering;
  if (normalized.includes('decor') || normalized.includes('flower') || normalized.includes('floral')) return VENDOR_SERVICE_CONFIG.Decor;
  if (normalized.includes('tent') || normalized.includes('marquee') || normalized.includes('weather')) return VENDOR_SERVICE_CONFIG.MarqueeTent;
  if (normalized.includes('power') || normalized.includes('gen') || normalized.includes('generator')) return VENDOR_SERVICE_CONFIG.PowerBackup;
  if (normalized.includes('refresh') || normalized.includes('tea') || normalized.includes('coffee') || normalized.includes('drink')) return VENDOR_SERVICE_CONFIG.Refreshments;

  return VENDOR_SERVICE_CONFIG[catKey] || {
    label: catKey,
    shortLabel: catKey,
    icon: '📦',
    defaultPackage: 'Standard Service Package',
    defaultPrice: 5000,
    placeholderName: 'e.g. Service Partner',
    placeholderDescription: 'Describe your service offerings...',
    tierSample: 'Custom Service'
  };
};

const ALL_8_CAT_CARDS = [
  { key: 'SoundLighting', title: 'Sound & Lighting', icon: '🔊', price: 'From Rs. 40,000 - 250,000', desc: 'Concert line arrays, moving heads, wireless mics & ambient trussing.' },
  { key: 'Decor', title: 'Decor & Stage', icon: '🌸', price: 'From Rs. 30,000 - 200,000', desc: 'Royal floral stage drapes, bespoke table styling & entrance tunnel arches.' },
  { key: 'Photography', title: 'Photography & Media', icon: '📸', price: 'From Rs. 35,000 - 250,000', desc: '4K cinema video, drone photography, senior camera team & photo albums.' },
  { key: 'Cake', title: 'Cakes & Desserts', icon: '🎂', price: 'From Rs. 12,000 - 65,000', desc: 'Artisan tiered wedding cakes, birthday gateaus & dessert table styling.' },
  { key: 'Transport', title: 'VIP & Bridal Transport', icon: '🚗', price: 'From Rs. 20,000 - 95,000', desc: 'Vintage Rolls Royce, Mercedes S-Class, BMW sedans & VIP 14-seater vans.' },
  { key: 'Catering', title: 'Catering Buffets', icon: '🍽️', price: 'From Rs. 2,500 - 8,500/plate', desc: '5-7 course international banquets, live cooking & action food stations.' },
  { key: 'Refreshments', title: 'Drinks & Refreshments', icon: '☕', price: 'From Rs. 250 - 950/head', desc: 'Ceylon artisanal teas, fresh tropical juices, mocktail bars & live food stations.' },
  { key: 'MarqueeTent', title: 'Tents & Safeguards', icon: '🎪', price: 'From Rs. 45,000 - 220,000', desc: 'Clear-roof transparent marquee tents, rain shelters & pagoda setups.' },
  { key: 'PowerBackup', title: 'Power Backup & Gens', icon: '⚡', price: 'From Rs. 20,000 - 160,000', desc: 'Soundproof diesel generators (15-100 kVA) with ATS & on-site technicians.' },
];

export const VendorPortal: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'register'>('dashboard');

  // Form State
  const [businessName, setBusinessName] = useState('');
  const [category, setCategory] = useState('SoundLighting');
  const [contactNumber, setContactNumber] = useState('');
  const [description, setDescription] = useState('');
  const [packageName, setPackageName] = useState('');
  const [packagePrice, setPackagePrice] = useState(180000);
  const [selectedTierName, setSelectedTierName] = useState('');
  const [assignedBookings, setAssignedBookings] = useState<any[]>([]);
  const [loadingBookings, setLoadingBookings] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [registeredSuccess, setRegisteredSuccess] = useState(false);

  const selectedCategoryConfig = VENDOR_SERVICE_CONFIG[category] || getCategoryInfo(category);

  // Current Logged-in Vendor Identity
  const [userName, setUserName] = useState(authService.getUserName());
  const [userEmail, setUserEmail] = useState(authService.getUserEmail());
  const userKey = (userEmail || userName || 'vendor').toLowerCase().trim();

  useEffect(() => {
    const handleProfileUpdate = () => {
      setUserName(authService.getUserName());
      setUserEmail(authService.getUserEmail());
    };
    window.addEventListener('user_profile_updated', handleProfileUpdate);
    return () => window.removeEventListener('user_profile_updated', handleProfileUpdate);
  }, []);

  // Active vendors strictly tied to the logged-in user
  const [myVendors, setMyVendors] = useState<VendorItem[]>(() => {
    try {
      if (userKey) {
        const saved = localStorage.getItem(`eventcraft_vendor_list_${userKey}`);
        if (saved) return JSON.parse(saved);
        const singleSavedId = localStorage.getItem(`eventcraft_vendor_id_${userKey}`);
        if (singleSavedId) {
          return [{ id: singleSavedId, vendorId: singleSavedId, businessName: 'Loading...', category: '', contactNumber: '', verificationStatus: 'Pending' }] as any;
        }
      }
    } catch {}
    return [];
  });

  const [selectedVendorId, setSelectedVendorId] = useState<string | null>(() => {
    try {
      return localStorage.getItem(`eventcraft_active_vendor_id_${userKey}`) || null;
    } catch {}
    return null;
  });

  const currentVendor = (myVendors.length > 0)
    ? (myVendors.find(v => (v.vendorId || v.id) === selectedVendorId) || myVendors[0])
    : null;

  // Sync with Backend API
  const syncMyVendors = async () => {
    try {
      const currentUserId = authService.getUserId();
      // Fetch all vendors from API
      const allVendors = await vendorService.getVendors();
      if (Array.isArray(allVendors)) {
        const savedIds: string[] = [];
        try {
          const rawIds = localStorage.getItem(`eventcraft_vendor_ids_${userKey}`);
          if (rawIds) savedIds.push(...JSON.parse(rawIds));
          const singleId = localStorage.getItem(`eventcraft_vendor_id_${userKey}`);
          if (singleId && !savedIds.includes(singleId)) savedIds.push(singleId);
        } catch {}

        const userPhone = (authService.getUserPhone() || '').replace(/\D/g, '');
        const normUserName = (userName || '').toLowerCase().trim();

        const userBusinesses = allVendors.filter(v => {
          const vId = (v.vendorId || v.id || '').toString();
          const matchesUserId = !!(currentUserId && v.userId && v.userId.toLowerCase() === currentUserId.toLowerCase());
          const matchesSavedId = savedIds.includes(vId);
          const vPhone = (v.contactNumber || v.contact || '').replace(/\D/g, '');
          const matchesPhone = !!(userPhone && vPhone && (vPhone.includes(userPhone) || userPhone.includes(vPhone)));
          const vName = (v.businessName || v.name || '').toLowerCase();
          const matchesName = !!(normUserName && (vName.includes(normUserName) || (normUserName.includes('sumane') && vName.includes('sumane'))));

          return matchesUserId || matchesSavedId || matchesPhone || matchesName;
        });

        if (userBusinesses.length > 0) {
          const mapped = userBusinesses.map(v => ({
            ...v,
            id: v.vendorId || v.id,
            vendorId: v.vendorId || v.id,
            status: v.verificationStatus || v.status || 'Pending',
            verificationStatus: v.verificationStatus || v.status || 'Pending',
          }));
          setMyVendors(mapped);
          try {
            localStorage.setItem(`eventcraft_vendor_list_${userKey}`, JSON.stringify(mapped));
            const ids = mapped.map(v => v.id || v.vendorId);
            localStorage.setItem(`eventcraft_vendor_ids_${userKey}`, JSON.stringify(ids));
          } catch {}

          if (!selectedVendorId && mapped.length > 0) {
            const firstId = mapped[0].id || mapped[0].vendorId || null;
            setSelectedVendorId(firstId);
            if (firstId) localStorage.setItem(`eventcraft_active_vendor_id_${userKey}`, firstId);
          }
        }
      }
    } catch (e) {
      console.error('Sync error', e);
    }
  };

  // Fetch Assigned Bookings / Work Orders
  const fetchAssignedEvents = async () => {
    try {
      const vId = currentVendor?.vendorId || currentVendor?.id;
      const uId = authService.getUserId();
      if (!vId && !uId) return;
      setLoadingBookings(true);
      const data = await vendorService.getAssignedEvents(vId, uId);
      if (Array.isArray(data)) {
        setAssignedBookings(data);
      }
    } catch (err) {
      console.error('Error fetching assigned bookings', err);
    } finally {
      setLoadingBookings(false);
    }
  };

  useEffect(() => {
    syncMyVendors();
    const interval = setInterval(syncMyVendors, 4000); // Check every 4 seconds
    return () => clearInterval(interval);
  }, [userKey, selectedVendorId]);

  useEffect(() => {
    fetchAssignedEvents();
    const interval = setInterval(fetchAssignedEvents, 5000);
    return () => clearInterval(interval);
  }, [currentVendor?.vendorId, currentVendor?.id]);

  const handleCategoryChange = (newCat: string) => {
    setCategory(newCat);
    setSelectedTierName('');
    const tiers = CATEGORY_TIERS_MAP[newCat] || [];
    if (tiers.length > 0) {
      const defaultTier = tiers[0];
      setPackageName(defaultTier.name);
      setPackagePrice(defaultTier.price);
      setDescription(defaultTier.description);
      setSelectedTierName(defaultTier.name);
    } else {
      const config = VENDOR_SERVICE_CONFIG[newCat] || getCategoryInfo(newCat);
      if (config) {
        setPackagePrice(config.defaultPrice);
      }
    }
  };

  const handleTierSelect = (tierName: string) => {
    setSelectedTierName(tierName);
    if (!tierName || tierName === 'custom') return;
    const tiers = CATEGORY_TIERS_MAP[category] || [];
    const found = tiers.find(t => t.name === tierName);
    if (found) {
      setPackageName(found.name);
      setPackagePrice(found.price);
      setDescription(found.description);
    }
  };

  const handleSelectCategoryToRegister = (catKey: string) => {
    setCategory(catKey);
    setSelectedTierName('');
    const tiers = CATEGORY_TIERS_MAP[catKey] || [];
    if (tiers.length > 0) {
      const defaultTier = tiers[0];
      setPackageName(defaultTier.name);
      setPackagePrice(defaultTier.price);
      setDescription(defaultTier.description);
      setSelectedTierName(defaultTier.name);
    } else {
      const config = VENDOR_SERVICE_CONFIG[catKey] || getCategoryInfo(catKey);
      if (config) {
        setPackagePrice(config.defaultPrice);
      }
    }
    setActiveTab('register');
  };

  // Handle New Vendor Registration
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessName || !contactNumber) return;

    try {
      setSubmitting(true);
      const currentUserId = authService.getUserId();

      // Save to backend API
      const registeredVendor = await vendorService.registerVendor({
        businessName,
        category,
        contactNumber,
        description: description || packageName || selectedCategoryConfig.defaultPackage,
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: Number(packagePrice) || selectedCategoryConfig.defaultPrice,
        userId: currentUserId || undefined
      });

      const newVendorId = (registeredVendor as any).vendorId || registeredVendor.id;
      
      const newVendorData: any = {
        ...registeredVendor,
        id: newVendorId,
        vendorId: newVendorId,
        verificationStatus: (registeredVendor as any).verificationStatus || 'Pending',
        status: (registeredVendor as any).verificationStatus || 'Pending',
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: Number(packagePrice) || selectedCategoryConfig.defaultPrice,
        userId: currentUserId
      };

      setMyVendors(prev => {
        const filtered = prev.filter(v => (v.vendorId || v.id) !== newVendorId);
        const updated = [newVendorData, ...filtered];
        try {
          localStorage.setItem(`eventcraft_vendor_list_${userKey}`, JSON.stringify(updated));
          const ids = updated.map(v => v.id || (v as any).vendorId);
          localStorage.setItem(`eventcraft_vendor_ids_${userKey}`, JSON.stringify(ids));
        } catch {}
        return updated;
      });

      setSelectedVendorId(newVendorId);
      if (userKey) {
        localStorage.setItem(`eventcraft_active_vendor_id_${userKey}`, newVendorId);
      }

      setRegisteredSuccess(true);
      setActiveTab('dashboard');
      // Reset form
      setBusinessName('');
      setContactNumber('');
      setDescription('');
      setPackageName('');
    } catch (err) {
      console.error("Backend vendor registration failed:", err);
      alert("Failed to register vendor. Please ensure backend API is running.");
    } finally {
      setSubmitting(false);
    }
  };

  const activeCategoryInfo = currentVendor ? getCategoryInfo(currentVendor.category) : null;

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Top Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
        <div>
          <div className="flex items-center space-x-2">
            <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
              Supplier & Partner Portal
            </span>
            <span className="text-xs text-slate-400">• Member 1 Component</span>
          </div>
          <h1 className="text-2xl font-black mt-2">Vendor Business Management & Onboarding</h1>
          <p className="text-slate-400 text-sm mt-1">Onboard your business across all 8 certified event services for autonomous AI-assisted event proposal allocation.</p>
        </div>

        {/* Portal Tabs */}
        <div className="flex space-x-2 bg-slate-800 p-1.5 rounded-xl border border-slate-700">
          <button
            onClick={() => setActiveTab('dashboard')}
            className={`px-4 py-2 rounded-lg text-xs font-semibold flex items-center space-x-1.5 transition ${
              activeTab === 'dashboard' ? 'bg-indigo-600 text-white shadow-sm' : 'text-slate-300 hover:text-white'
            }`}
          >
            <Building2 className="w-3.5 h-3.5" />
            <span>My Business Status {myVendors.length > 0 ? `(${myVendors.length})` : ''}</span>
          </button>
          <button
            onClick={() => setActiveTab('register')}
            className={`px-4 py-2 rounded-lg text-xs font-semibold flex items-center space-x-1.5 transition ${
              activeTab === 'register' ? 'bg-indigo-600 text-white shadow-sm' : 'text-slate-300 hover:text-white'
            }`}
          >
            <PlusCircle className="w-3.5 h-3.5" />
            <span>Register New Business</span>
          </button>
        </div>
      </div>

      {registeredSuccess && (
        <div className="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl text-emerald-900 text-sm flex items-center justify-between shadow-sm">
          <div className="flex items-center space-x-2">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0" />
            <span>
              <strong>Registration Submitted!</strong> Your business profile has been submitted and is currently in <strong>Pending Review</strong> status awaiting Operations Manager audit.
            </span>
          </div>
          <button onClick={() => setRegisteredSuccess(false)} className="text-emerald-700 hover:text-emerald-900 font-bold">&times;</button>
        </div>
      )}

      {/* VIEW 1: MY VENDOR DASHBOARD */}
      {activeTab === 'dashboard' && (
        currentVendor ? (
          <div className="space-y-6">

            {/* Multiple Business Switcher Bar */}
            {myVendors.length > 1 && (
              <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-4 flex flex-wrap items-center gap-3">
                <span className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center mr-1">
                  <Building2 className="w-4 h-4 mr-1 text-indigo-600" />
                  Your Businesses ({myVendors.length}):
                </span>
                <div className="flex flex-wrap items-center gap-2">
                  {myVendors.map(v => {
                    const isSelected = (v.vendorId || v.id) === (currentVendor?.vendorId || currentVendor?.id);
                    const cat = getCategoryInfo(v.category);
                    return (
                      <button
                        key={v.vendorId || v.id}
                        onClick={() => {
                          const id = v.vendorId || v.id;
                          if (id) {
                            setSelectedVendorId(id);
                            localStorage.setItem(`eventcraft_active_vendor_id_${userKey}`, id);
                          }
                        }}
                        className={`px-3 py-1.5 rounded-xl text-xs font-bold flex items-center space-x-2 border transition ${
                          isSelected 
                            ? 'bg-slate-900 text-white border-slate-900 shadow-sm ring-2 ring-indigo-500/30' 
                            : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                        }`}
                      >
                        <span>{cat?.icon || '🏪'}</span>
                        <span>{v.businessName || v.name}</span>
                        <span className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
                          v.verificationStatus === 'Verified' 
                            ? (isSelected ? 'bg-emerald-500 text-white' : 'bg-emerald-100 text-emerald-800')
                            : (isSelected ? 'bg-amber-500 text-white' : 'bg-amber-100 text-amber-800')
                        }`}>
                          {v.verificationStatus === 'Verified' ? 'Active' : 'Pending'}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>
            )}
            
            {/* Status Hero Card */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Registered Partner Profile</span>
                  <div className="flex items-center space-x-2.5 mt-1">
                    <span className="text-2xl">{activeCategoryInfo?.icon || '🏪'}</span>
                    <h2 className="text-2xl font-black text-slate-900">{currentVendor.businessName || currentVendor.name}</h2>
                  </div>
                  <div className="flex flex-wrap items-center gap-3 mt-2 text-xs text-slate-500">
                    <span className="px-2.5 py-1 bg-indigo-50 text-indigo-700 font-bold rounded-md border border-indigo-100 flex items-center space-x-1">
                      <span>{activeCategoryInfo?.icon}</span>
                      <span>Category: {activeCategoryInfo?.label || currentVendor.category}</span>
                    </span>
                    <span className="flex items-center"><Phone className="w-3 h-3 mr-1 text-slate-400" />{currentVendor.contactNumber || currentVendor.contact}</span>
                  </div>
                </div>

                {/* Status Badge */}
                <div className="flex flex-col items-end">
                  <span className="text-xs font-semibold text-slate-400 uppercase mb-1">Audit Verification Status</span>
                  {currentVendor.verificationStatus === 'Verified' ? (
                    <div className="flex items-center space-x-2 px-4 py-2 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl font-bold text-sm shadow-sm">
                      <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                      <span>Verified & Certified Partner</span>
                    </div>
                  ) : currentVendor.verificationStatus === 'Rejected' ? (
                    <div className="flex items-center space-x-2 px-4 py-2 bg-rose-50 text-rose-700 border border-rose-200 rounded-xl font-bold text-sm shadow-sm">
                      <XCircle className="w-5 h-5 text-rose-600" />
                      <span>Application Declined</span>
                    </div>
                  ) : (
                    <div className="flex items-center space-x-2 px-4 py-2 bg-amber-50 text-amber-700 border border-amber-200 rounded-xl font-bold text-sm shadow-sm animate-pulse">
                      <Clock className="w-5 h-5 text-amber-600" />
                      <span>Under Review (Pending Approval)</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Explanation & Instructions based on status */}
              <div className="mt-6">
                {currentVendor.verificationStatus === 'Verified' ? (
                  <div className="p-4 bg-emerald-50/70 border border-emerald-200 rounded-xl text-emerald-900 text-sm">
                    <div className="flex items-start space-x-3">
                      <Sparkles className="w-5 h-5 text-emerald-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="font-bold">Autonomous AI Recommendation Engine Integration: Active!</h4>
                        <p className="text-xs text-emerald-800 mt-1">
                          Your services and equipment packages are actively indexed by the <strong>EventCraft Multi-Agent Planner</strong>. When customers submit event requests matching <strong>{activeCategoryInfo?.label || currentVendor.category}</strong>, your services are automatically curated into client proposals!
                        </p>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="p-4 bg-amber-50/70 border border-amber-200 rounded-xl text-amber-900 text-sm">
                    <div className="flex items-start space-x-3">
                      <AlertCircle className="w-5 h-5 text-amber-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="font-bold">Waiting for Operations Manager Verification</h4>
                        <p className="text-xs text-amber-800 mt-1">
                          Your application is currently listed in the <strong>Pending Verification Requests Queue</strong> of the Operations Manager dashboard.
                        </p>
                        <p className="text-xs text-amber-700/80 mt-2 flex items-center">
                          <Clock className="w-3.5 h-3.5 mr-1 text-amber-600" />
                          Audited by EventCraft Operations Management. Once verified, your status will update automatically.
                        </p>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Assigned Event Bookings & Live Work Orders */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-2 mb-4">
                <div>
                  <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                    <span className="text-xl">🔔</span>
                    <span>My Assigned Event Bookings & Live Work Orders ({assignedBookings.length})</span>
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Live client event orders assigned to your verified business by EventCraft Operations Managers.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={fetchAssignedEvents}
                  disabled={loadingBookings}
                  className="inline-flex items-center space-x-1.5 px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold text-xs rounded-lg border border-indigo-200 transition disabled:opacity-50"
                >
                  <span>🔄 {loadingBookings ? 'Refreshing...' : 'Refresh Orders'}</span>
                </button>
              </div>

              {loadingBookings ? (
                <div className="py-8 text-center text-xs text-slate-400">Loading assigned bookings...</div>
              ) : assignedBookings.length > 0 ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {assignedBookings.map((b: any, idx: number) => (
                    <div 
                      key={b.eventId ? `${b.eventId}-${idx}` : idx} 
                      className="p-4 rounded-xl border border-indigo-200 bg-indigo-50/30 hover:border-indigo-400 transition shadow-xs"
                    >
                      <div className="flex items-start justify-between">
                        <div>
                          <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-indigo-100 text-indigo-800">
                            {b.category || 'Service'} Assignment
                          </span>
                          <h4 className="font-black text-slate-900 text-sm mt-1.5">{b.eventTitle}</h4>
                          <p className="text-xs text-slate-600 mt-1 flex flex-wrap items-center gap-1.5">
                            <span>📍 {b.venueName || 'Venue TBD'}</span>
                            <span className="text-slate-300">•</span>
                            <span>📅 {b.targetDate ? new Date(b.targetDate).toLocaleDateString() : 'Date TBD'}</span>
                            {b.eventSession && <span className="text-slate-500">({b.eventSession})</span>}
                          </p>
                        </div>
                        <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full whitespace-nowrap ${
                          b.bookingStatus === 'ApprovedByManager' || b.bookingStatus === 'Confirmed'
                            ? 'bg-emerald-100 text-emerald-800'
                            : 'bg-amber-100 text-amber-800'
                        }`}>
                          {b.bookingStatus || 'Assigned'}
                        </span>
                      </div>

                      <div className="mt-3 pt-3 border-t border-indigo-100 text-xs space-y-1">
                        <div className="flex justify-between text-slate-700">
                          <span className="text-slate-500">Booked Package:</span>
                          <span className="font-bold text-slate-900">{b.packageName || 'Standard Service'}</span>
                        </div>
                        <div className="flex justify-between text-slate-700">
                          <span className="text-slate-500">Agreed Vendor Payout:</span>
                          <span className="font-bold text-emerald-700">Rs. {Number(b.agreedPayout || 0).toLocaleString()}</span>
                        </div>
                        {b.advancePaid > 0 && (
                          <div className="flex justify-between text-slate-700">
                            <span className="text-slate-500">Advance Paid:</span>
                            <span className="font-semibold text-indigo-700">Rs. {Number(b.advancePaid || 0).toLocaleString()}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="p-6 text-center border border-dashed border-slate-200 rounded-xl bg-slate-50/50">
                  <Clock className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-xs font-semibold text-slate-600">No active event work orders assigned yet.</p>
                  <p className="text-[11px] text-slate-400 mt-1 max-w-md mx-auto">
                    When Operations Managers approve event proposals matching your category, your confirmed assignments and agreed payouts will appear here in real-time.
                  </p>
                </div>
              )}
            </div>

            {/* Catalog & Equipment Breakdown - All Registered Businesses */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-2 mb-4">
                <div>
                  <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                    <Layers className="w-4 h-4 text-indigo-600" />
                    <span>My Registered Services & Businesses ({myVendors.length})</span>
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">All registered commercial profiles and equipment rate-cards under your account.</p>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="text-xs bg-slate-100 text-slate-600 px-2.5 py-1 rounded-md font-semibold">Cloud DB Live Sync</span>
                  <button
                    onClick={() => setActiveTab('register')}
                    className="inline-flex items-center space-x-1.5 px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold text-xs rounded-lg border border-indigo-200 transition"
                  >
                    <PlusCircle className="w-3.5 h-3.5" />
                    <span>+ Add Service</span>
                  </button>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {myVendors.map(vendor => {
                  const catInfo = getCategoryInfo(vendor.category);
                  const isFocus = (vendor.vendorId || vendor.id) === (currentVendor?.vendorId || currentVendor?.id);
                  return (
                    <div
                      key={vendor.vendorId || vendor.id}
                      onClick={() => {
                        const id = vendor.vendorId || vendor.id;
                        if (id) {
                          setSelectedVendorId(id);
                          localStorage.setItem(`eventcraft_active_vendor_id_${userKey}`, id);
                        }
                      }}
                      className={`p-4 rounded-xl border cursor-pointer transition ${
                        isFocus ? 'border-indigo-400 bg-indigo-50/20 ring-2 ring-indigo-400/20 shadow-sm' : 'border-slate-200 bg-slate-50 hover:border-slate-300'
                      }`}
                    >
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="flex items-center space-x-2">
                            <span className="text-lg">{catInfo?.icon || '📦'}</span>
                            <h4 className="font-bold text-slate-900 text-sm">{vendor.businessName || vendor.name}</h4>
                            {isFocus && (
                              <span className="text-[10px] font-bold bg-indigo-600 text-white px-1.5 py-0.5 rounded">Active Focus</span>
                            )}
                          </div>
                          <p className="text-xs text-indigo-600 font-semibold mt-1">
                            Package: {vendor.packageName || vendor.adminRemarks || catInfo?.defaultPackage || 'Standard Service Package'}
                          </p>
                          <p className="text-xs text-slate-500 mt-1 flex items-center space-x-1">
                            <Tag className="w-3 h-3 text-slate-400" />
                            <span>{catInfo?.label || vendor.category}</span>
                            <span className="text-slate-300">|</span>
                            <span>📞 {vendor.contactNumber || vendor.contact}</span>
                          </p>
                          <p className="text-xs font-bold text-slate-900 mt-2">
                            Starting Price: <span className="text-indigo-600 font-bold">Rs. {Number(vendor.packagePrice || catInfo?.defaultPrice || 5000).toLocaleString()}</span>
                          </p>
                        </div>
                        <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full whitespace-nowrap ${
                          vendor.verificationStatus === 'Verified' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                        }`}>
                          {vendor.verificationStatus === 'Verified' ? 'Active in AI Catalog' : 'Pending Verification'}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* EventCraft Network 8 Service Categories Overview */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex justify-between items-center mb-4">
                <div>
                  <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                    <Sparkles className="w-4 h-4 text-indigo-600" />
                    <span>EventCraft 8 Service Categories & Tiered Catalog</span>
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">Explore standard rate cards and active AI allocation indexing across the entire supplier network.</p>
                </div>
                <span className="text-xs bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full font-bold border border-indigo-200">
                  8 Services Certified
                </span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                {ALL_8_CAT_CARDS.map(cat => (
                  <div key={cat.key} className="p-3.5 rounded-xl border border-slate-200 bg-slate-50/70 hover:bg-white hover:border-indigo-300 transition shadow-xs">
                    <div className="flex items-center space-x-2 mb-1.5">
                      <span className="text-xl">{cat.icon}</span>
                      <h4 className="font-bold text-slate-900 text-xs">{cat.title}</h4>
                    </div>
                    <p className="text-[11px] text-indigo-600 font-bold mb-1">{cat.price}</p>
                    <p className="text-[11px] text-slate-500 leading-tight line-clamp-2">{cat.desc}</p>
                  </div>
                ))}
              </div>
            </div>

          </div>
        ) : (
          /* Empty state for a newly registered vendor who hasn't onboarded a business yet */
          <div className="space-y-6">
            <div className="bg-white rounded-2xl border border-dashed border-slate-300 p-8 text-center shadow-sm max-w-3xl mx-auto">
              <div className="w-16 h-16 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-indigo-100 shadow-sm">
                <Building2 className="w-8 h-8" />
              </div>
              <span className="text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-200">
                Account Active • Onboarding Required
              </span>
              <h2 className="text-2xl font-black text-slate-900 mt-4">Welcome to EventCraft, {userName}!</h2>
              <p className="text-slate-500 text-sm max-w-xl mx-auto mt-2 leading-relaxed">
                You haven't registered your business profile yet. Register your catering, audiovisual, decor, photography, cakes, VIP transport, marquee tents, or power backup services below to get audited and verified by EventCraft Operations Management.
              </p>
              <div className="pt-6">
                <button
                  onClick={() => setActiveTab('register')}
                  className="inline-flex items-center space-x-2 px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-sm rounded-xl shadow-md transition hover:scale-[1.02]"
                >
                  <PlusCircle className="w-4 h-4" />
                  <span>Register Your Business Profile Now</span>
                </button>
              </div>
            </div>

            {/* Quick 8 Category Selection Cards */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 max-w-5xl mx-auto">
              <div className="mb-4">
                <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                  <Sparkles className="w-4 h-4 text-indigo-600" />
                  <span>Select Your Service Category to Start Onboarding (8 Categories)</span>
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">Click on your industry category below to automatically configure your application form.</p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                {ALL_8_CAT_CARDS.map(cat => (
                  <button
                    key={cat.key}
                    onClick={() => handleSelectCategoryToRegister(cat.key)}
                    className="p-4 rounded-xl border border-slate-200 bg-slate-50 text-left hover:border-indigo-500 hover:bg-indigo-50/40 transition group flex flex-col justify-between"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-2xl">{cat.icon}</span>
                        <ChevronRight className="w-4 h-4 text-slate-400 group-hover:text-indigo-600 transition" />
                      </div>
                      <h4 className="font-bold text-slate-900 text-xs mb-1 group-hover:text-indigo-600">{cat.title}</h4>
                      <p className="text-[11px] text-slate-500 line-clamp-2 leading-tight">{cat.desc}</p>
                    </div>
                    <div className="mt-3 pt-2 border-t border-slate-200/60 text-[11px] font-bold text-indigo-600 flex items-center justify-between">
                      <span>{cat.price}</span>
                      <span className="text-[10px] text-indigo-500 underline">Register</span>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )
      )}

      {/* VIEW 2: VENDOR REGISTRATION FORM */}
      {activeTab === 'register' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 max-w-2xl mx-auto">
          <div className="mb-6">
            <h2 className="text-xl font-bold text-slate-900">Partner Business Registration Form</h2>
            <p className="text-slate-500 text-xs mt-1">Fill in your business details across any of our 8 certified service categories to apply for verified vendor status.</p>
          </div>

          <form onSubmit={handleRegister} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Business / Company Name *</label>
              <input 
                type="text"
                required
                value={businessName}
                onChange={e => setBusinessName(e.target.value)}
                placeholder={selectedCategoryConfig.placeholderName}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Service Category (9 Categories) *</label>
                <select
                  value={category}
                  onChange={e => handleCategoryChange(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 font-medium"
                >
                  <option value="SoundLighting">🔊 Sound & Lighting</option>
                  <option value="Decor">🌸 Decor & Stage</option>
                  <option value="Photography">📸 Photography & Media</option>
                  <option value="Cake">🎂 Cakes & Celebration Desserts</option>
                  <option value="Transport">🚗 VIP & Luxury Transport</option>
                  <option value="Catering">🍽️ Catering Buffets</option>
                  <option value="Refreshments">☕ Welcome Drinks & Refreshments</option>
                  <option value="MarqueeTent">🎪 Tents & Safeguards</option>
                  <option value="PowerBackup">⚡ Power Backup & Generators</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Official Contact Number *</label>
                <input 
                  type="text"
                  required
                  value={contactNumber}
                  onChange={e => setContactNumber(e.target.value)}
                  placeholder="e.g. +94 77 987 6543"
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            {/* Standard Service Tier Selector */}
            <div className="bg-indigo-50/60 p-3.5 rounded-xl border border-indigo-100">
              <label className="block text-xs font-bold text-indigo-950 uppercase mb-1 flex items-center justify-between">
                <span>Select Standard Service Tier (Optional Auto-Fill)</span>
                <span className="text-[10px] text-indigo-600 lowercase font-normal">Choose tier to populate benchmark specs</span>
              </label>
              <select
                value={selectedTierName}
                onChange={e => handleTierSelect(e.target.value)}
                className="w-full px-3 py-2 border border-indigo-200 rounded-lg text-xs bg-white text-slate-800 font-semibold focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="">-- Choose a standard service tier (Tier 1 - 4) --</option>
                {(CATEGORY_TIERS_MAP[category] || []).map(t => (
                  <option key={t.name} value={t.name}>
                    {t.tier}: {t.name} — (Benchmark: Rs. {t.price.toLocaleString()})
                  </option>
                ))}
                <option value="custom">✏️ Custom Package Name & Rate</option>
              </select>
              <p className="text-[11px] text-slate-500 mt-1">
                Selecting a tier auto-fills package title, starting unit price, and business specs. You can customize any field below.
              </p>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Primary Service Package Name</label>
              <input 
                type="text"
                value={packageName}
                onChange={e => setPackageName(e.target.value)}
                placeholder={selectedCategoryConfig.defaultPackage}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Starting Unit Price (LKR)</label>
                <input 
                  type="number"
                  value={packagePrice}
                  onChange={e => setPackagePrice(Number(e.target.value))}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Operating Cities</label>
                <input 
                  type="text"
                  placeholder="Colombo, Kandy, Galle"
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Business Description / Accreditation</label>
              <textarea 
                rows={3}
                value={description}
                onChange={e => setDescription(e.target.value)}
                placeholder={selectedCategoryConfig.placeholderDescription}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={submitting}
                className="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-sm rounded-xl shadow-md transition flex items-center justify-center space-x-2 disabled:opacity-50"
              >
                <ShieldCheck className="w-4 h-4" />
                <span>{submitting ? 'Submitting Application...' : 'Submit Application for Manager Audit'}</span>
              </button>
            </div>
          </form>
        </div>
      )}

    </div>
  );
};

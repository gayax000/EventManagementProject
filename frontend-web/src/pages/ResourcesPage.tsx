import React, { useState, useEffect } from 'react';
import { Package, CloudRain, Cpu, Plus, Check, Search } from 'lucide-react';

export interface ResourceItem {
  id: string;
  name: string;
  type: string;
  unitPrice: number;
  available: number;
}

const DEFAULT_RESOURCES: ResourceItem[] = [
  // 1. Tents & Weather Safeguards (MarqueeTent)
  { id: 't1', name: 'Royal Clear-Roof Transparent Marquee Tent (40x60 ft)', type: 'MarqueeTent', unitPrice: 220000, available: 4 },
  { id: 't2', name: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)', type: 'MarqueeTent', unitPrice: 150000, available: 10 },
  { id: 't3', name: 'White Waterproof Pagoda / Gazebo Tent Set (Set of 4)', type: 'MarqueeTent', unitPrice: 110000, available: 8 },
  { id: 't4', name: 'Black Weatherproof Heavy-Duty Canopy Tent (20x20 ft)', type: 'MarqueeTent', unitPrice: 80000, available: 12 },
  { id: 't5', name: 'Compact Pop-Up Rain Shelter Canopy (10x20 ft)', type: 'MarqueeTent', unitPrice: 45000, available: 15 },

  // 2. Sound & Intelligent Lighting (SoundLighting)
  { id: 's1', name: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses', type: 'SoundLighting', unitPrice: 250000, available: 6 },
  { id: 's2', name: 'Concert Line-Array Sound & Digital Mixer Package', type: 'SoundLighting', unitPrice: 180000, available: 12 },
  { id: 's3', name: 'Standard Stage Audio + Ambient Warm LED PAR Cans', type: 'SoundLighting', unitPrice: 120000, available: 15 },
  { id: 's4', name: 'Acoustic PA System + Wireless Dual Mics + Mood Uplights', type: 'SoundLighting', unitPrice: 75000, available: 20 },
  { id: 's5', name: 'Compact Speech PA Kit + 2 Speakers + Bluetooth Hub', type: 'SoundLighting', unitPrice: 40000, available: 18 },

  // 3. Floral & Stage Decoration (Decor)
  { id: 'd1', name: 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor', type: 'Decor', unitPrice: 200000, available: 5 },
  { id: 'd2', name: 'Thematic Floral Stage + Entrance Tunnel Arch Decor', type: 'Decor', unitPrice: 130000, available: 8 },
  { id: 'd3', name: 'Floral Stage & Tablescape Theme Decoration', type: 'Decor', unitPrice: 80000, available: 15 },
  { id: 'd4', name: 'Fairy-Light Star Backdrop + Geometric Floral Frame', type: 'Decor', unitPrice: 50000, available: 14 },
  { id: 'd5', name: 'Minimalist Floral Arch + Cake Table Styling', type: 'Decor', unitPrice: 30000, available: 20 },

  // 4. In-House Photography & Media (Photography)
  { id: 'p1', name: 'Royal Cinematic Cinema Rig + Drone + 3 Senior Photographers', type: 'Photography', unitPrice: 250000, available: 4 },
  { id: 'p2', name: 'Master Wedding Photography + 4K Highlights Video + Album', type: 'Photography', unitPrice: 160000, available: 8 },
  { id: 'p3', name: 'Professional Event Coverage (2 Photographers + Edited Soft Copies)', type: 'Photography', unitPrice: 100000, available: 12 },
  { id: 'p4', name: 'Standard Event Photography (Full Day Coverage + Highlight Album)', type: 'Photography', unitPrice: 60000, available: 15 },
  { id: 'p5', name: 'Compact Event Photography (4-Hour Coverage + Raw & Graded)', type: 'Photography', unitPrice: 35000, available: 18 },

  // 5. Celebration Cakes (Cake)
  { id: 'c1', name: '5-Tier Royal Handcrafted Fondant Wedding Cake', type: 'Cake', unitPrice: 65000, available: 10 },
  { id: 'c2', name: '3-Tier Luxury Floral Wedding Cake', type: 'Cake', unitPrice: 45000, available: 12 },
  { id: 'c3', name: '3-Tier Grand Custom Thematic Birthday Cake', type: 'Cake', unitPrice: 35000, available: 15 },
  { id: 'c4', name: '2-Tier Signature Engagement / Anniversary Cake', type: 'Cake', unitPrice: 28000, available: 18 },
  { id: 'c5', name: 'Classic Celebration Birthday Gateau', type: 'Cake', unitPrice: 12000, available: 25 },

  // 6. Luxury Bridal & VIP Transport (Transport)
  { id: 'v1', name: 'Classic Vintage Rolls Royce / Jaguar Bridal Car', type: 'Transport', unitPrice: 95000, available: 4 },
  { id: 'v2', name: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan', type: 'Transport', unitPrice: 65000, available: 8 },
  { id: 'v3', name: 'BMW 5-Series Executive Bridal Sedan', type: 'Transport', unitPrice: 50000, available: 10 },
  { id: 'v4', name: 'Luxury High-Roof VIP Passenger Van (14-Seater)', type: 'Transport', unitPrice: 35000, available: 12 },
  { id: 'v5', name: 'Airport & Hotel Executive Transfer Sedan', type: 'Transport', unitPrice: 20000, available: 15 },

  // 7. Catering Packages (Per Plate) (CateringPackage)
  { id: 'cp1', name: 'Royal 7-Course International Gala Buffet (Seafood & Carvery)', type: 'CateringPackage', unitPrice: 8500, available: 1500 },
  { id: 'cp2', name: 'Executive Dinner Buffet (3 Meats, Seafood & Action Station)', type: 'CateringPackage', unitPrice: 6500, available: 2500 },
  { id: 'cp3', name: 'Premium Dinner Buffet B (2 Meats, Action Station & Desserts)', type: 'CateringPackage', unitPrice: 5000, available: 3000 },
  { id: 'cp4', name: 'Classic Sri Lankan & Asian Fusion Buffet (2 Meats)', type: 'CateringPackage', unitPrice: 3800, available: 4000 },
  { id: 'cp5', name: 'Cocktail High-Tea & Savoury Finger Food Platter Package', type: 'CateringPackage', unitPrice: 2500, available: 3500 },

  // 8. Power Backup & Generators (PowerBackup)
  { id: 'pb1', name: 'Industrial 100 kVA Synchronized Silent Dual Generator', type: 'PowerBackup', unitPrice: 160000, available: 4 },
  { id: 'pb2', name: 'Backup Diesel Silent Generator (60 kVA Heavy Duty)', type: 'PowerBackup', unitPrice: 90000, available: 10 },
  { id: 'pb3', name: 'Mid-Range 35 kVA Soundproof Outdoor Generator', type: 'PowerBackup', unitPrice: 60000, available: 12 },
  { id: 'pb4', name: 'Portable 15 kVA Diesel Generator Kit', type: 'PowerBackup', unitPrice: 35000, available: 15 },
  { id: 'pb5', name: 'Inverter Battery Emergency Pack + Mobile Floodlights', type: 'PowerBackup', unitPrice: 20000, available: 20 },
];

export const ResourcesPage: React.FC = () => {
  const [resources, setResources] = useState<ResourceItem[]>(() => {
    try {
      const saved = localStorage.getItem('eventcraft_resources_v2');
      return saved ? JSON.parse(saved) : DEFAULT_RESOURCES;
    } catch {
      return DEFAULT_RESOURCES;
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('eventcraft_resources_v2', JSON.stringify(resources));
    } catch (e) {
      console.error(e);
    }
  }, [resources]);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [newItemName, setNewItemName] = useState('');
  const [newItemType, setNewItemType] = useState('SoundLighting');
  const [newItemPrice, setNewItemPrice] = useState(50000);
  const [newItemUnits, setNewItemUnits] = useState(10);

  const handleAddItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newItemName) return;
    const newItem: ResourceItem = {
      id: Date.now().toString(),
      name: newItemName,
      type: newItemType,
      unitPrice: Number(newItemPrice),
      available: Number(newItemUnits),
    };
    setResources(prev => [newItem, ...prev]);
    setIsModalOpen(false);
    setNewItemName('');
  };

  const categories = [
    { label: 'All Resources', value: 'All' },
    { label: '🔊 Sound & Lighting', value: 'SoundLighting' },
    { label: '🌸 Decor & Stage', value: 'Decor' },
    { label: '📸 Photography', value: 'Photography' },
    { label: '🎂 Cakes', value: 'Cake' },
    { label: '🚗 VIP Transport', value: 'Transport' },
    { label: '🍽️ Catering Buffets', value: 'CateringPackage' },
    { label: '🎪 Tents & Safeguards', value: 'MarqueeTent' },
    { label: '⚡ Power Backup', value: 'PowerBackup' },
  ];

  const filteredResources = resources.filter(res => {
    const matchesCategory = selectedCategory === 'All' || res.type === selectedCategory;
    const matchesSearch = res.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          res.type.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Resource Inventory & AI Rules</h1>
          <p className="text-slate-500 text-sm mt-1">Manage catering packages, AV equipment, and autonomous weather risk contingency rules (Member 3 Component).</p>
        </div>
        <button 
          onClick={() => setIsModalOpen(true)}
          className="flex items-center space-x-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition shadow-sm"
        >
          <Plus className="w-4 h-4" />
          <span>New Inventory Item</span>
        </button>
      </div>

      {/* Add Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl max-w-md w-full p-6 border border-slate-200">
            <h3 className="text-lg font-bold text-slate-900 mb-4">Add New Resource / Package</h3>
            <form onSubmit={handleAddItem} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1">Item / Service Name</label>
                <input 
                  type="text" 
                  value={newItemName} 
                  onChange={e => setNewItemName(e.target.value)}
                  placeholder="e.g. 4K LED Screen Wall (10x20 ft)"
                  required
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-600 mb-1">Category</label>
                  <select 
                    value={newItemType} 
                    onChange={e => setNewItemType(e.target.value)}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white"
                  >
                    <option value="SoundLighting">🔊 Sound & Lighting</option>
                    <option value="Decor">🌸 Decor & Stage</option>
                    <option value="Photography">📸 Photography</option>
                    <option value="Cake">🎂 Celebration Cake</option>
                    <option value="Transport">🚗 VIP Transport</option>
                    <option value="CateringPackage">🍽️ Catering Package</option>
                    <option value="MarqueeTent">🎪 Marquee Tent</option>
                    <option value="PowerBackup">⚡ Power Backup</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-600 mb-1">Available Units</label>
                  <input 
                    type="number" 
                    value={newItemUnits} 
                    onChange={e => setNewItemUnits(Number(e.target.value))}
                    className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm"
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-600 mb-1">Unit Price (LKR)</label>
                <input 
                    type="number" 
                  value={newItemPrice} 
                  onChange={e => setNewItemPrice(Number(e.target.value))}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm"
                />
              </div>
              <div className="flex justify-end space-x-2 pt-2">
                <button 
                  type="button" 
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-slate-300 rounded-lg text-xs font-semibold text-slate-700 hover:bg-slate-50"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-xs font-semibold"
                >
                  Save Item
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* AI Safeguard Rule Banner */}
      <div className="mb-8 p-5 bg-gradient-to-r from-sky-900 to-indigo-900 text-white rounded-xl shadow-sm flex items-start space-x-4">
        <div className="p-2.5 bg-sky-500/20 rounded-lg border border-sky-400/30"><Cpu className="w-6 h-6 text-sky-400" /></div>
        <div>
          <h3 className="font-bold text-base flex items-center">
            Autonomous Safeguard Rule #01 Active
            <span className="ml-2 text-xs px-2 py-0.5 bg-emerald-500/30 text-emerald-300 border border-emerald-400/40 rounded-full">Automated</span>
          </h3>
          <p className="text-xs text-sky-200 mt-1">
            When target date weather forecast exceeds <strong>60% precipitation probability</strong> on outdoor venues, the <strong>Weather Risk Agent</strong> automatically appends a <em>Waterproof Marquee Tent (Rs. 150,000)</em> to the proposal.
          </p>
        </div>
      </div>

      {/* Search & Category Filter Tabs */}
      <div className="mb-6 space-y-3">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
          <div className="relative w-full sm:w-72">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input 
              type="text"
              placeholder="Search resource, tier, or equipment..."
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 text-xs bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-sky-500 shadow-sm"
            />
          </div>
          <span className="text-xs font-semibold text-slate-500">
            Showing {filteredResources.length} of {resources.length} in-house catalog items
          </span>
        </div>

        {/* Category Pills */}
        <div className="flex space-x-2 overflow-x-auto pb-2 scrollbar-none">
          {categories.map(cat => (
            <button
              key={cat.value}
              onClick={() => setSelectedCategory(cat.value)}
              className={`flex-shrink-0 px-3 py-1.5 rounded-lg text-xs font-semibold transition border ${
                selectedCategory === cat.value
                  ? 'bg-slate-900 text-white border-slate-900 shadow-sm'
                  : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>
      </div>

      {/* Resource Inventory Table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-200 bg-slate-50 flex items-center justify-between">
          <h3 className="font-bold text-slate-800 text-sm">Service & Equipment Packages</h3>
          <span className="text-xs text-slate-500">Live Inventory Sync ({filteredResources.length} Items)</span>
        </div>

        <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
          <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold">
            <tr>
              <th className="px-6 py-3">Resource Name</th>
              <th className="px-6 py-3">Type</th>
              <th className="px-6 py-3">Unit Price</th>
              <th className="px-6 py-3">Available Units</th>
              <th className="px-6 py-3">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200 text-slate-700">
            {filteredResources.map(res => (
              <tr key={res.id} className="hover:bg-slate-50">
                <td className="px-6 py-4 font-semibold text-slate-900 flex items-center">
                  <Package className="w-4 h-4 mr-2 text-indigo-500 flex-shrink-0" />
                  {res.name}
                </td>
                <td className="px-6 py-4"><span className="text-xs font-medium px-2.5 py-1 bg-slate-100 rounded-md text-slate-700">{res.type}</span></td>
                <td className="px-6 py-4 font-bold text-slate-900">Rs. {res.unitPrice.toLocaleString()}</td>
                <td className="px-6 py-4">{res.available} Units</td>
                <td className="px-6 py-4">
                  <span className="text-xs px-2.5 py-1 bg-emerald-50 text-emerald-700 rounded-full font-medium flex items-center w-max">
                    <Check className="w-3 h-3 mr-1" /> In Stock
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
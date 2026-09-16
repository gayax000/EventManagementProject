import React, { useState, useEffect } from 'react';
import { Package, CloudRain, Cpu, Plus, Check } from 'lucide-react';

export interface ResourceItem {
  id: string;
  name: string;
  type: string;
  unitPrice: number;
  available: number;
}

const DEFAULT_RESOURCES: ResourceItem[] = [
  { id: '1', name: 'Executive Dinner Buffet (3 Meats, Seafood)', type: 'CateringPackage', unitPrice: 6500, available: 2000 },
  { id: '2', name: 'Premium Dinner Buffet B (2 Meats, Action Station)', type: 'CateringPackage', unitPrice: 5000, available: 3000 },
  { id: '3', name: 'Concert Line-Array Sound & Digital Mixer', type: 'SoundLighting', unitPrice: 180000, available: 12 },
  { id: '4', name: 'Ambient Intelligent LED Moving Heads Rig', type: 'SoundLighting', unitPrice: 95000, available: 15 },
  { id: '5', name: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)', type: 'MarqueeTent', unitPrice: 150000, available: 15 },
  { id: '6', name: 'Backup Diesel Silent Generator (60 kVA)', type: 'PowerBackup', unitPrice: 90000, available: 10 },
];

export const ResourcesPage: React.FC = () => {
  const [resources, setResources] = useState<ResourceItem[]>(() => {
    try {
      const saved = localStorage.getItem('eventcraft_resources');
      return saved ? JSON.parse(saved) : DEFAULT_RESOURCES;
    } catch {
      return DEFAULT_RESOURCES;
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('eventcraft_resources', JSON.stringify(resources));
    } catch (e) {
      console.error(e);
    }
  }, [resources]);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newItemName, setNewItemName] = useState('');
  const [newItemType, setNewItemType] = useState('SoundLighting');
  const [newItemPrice, setNewItemPrice] = useState(50000);
  const [newItemUnits, setNewItemUnits] = useState(10);

  const handleAddItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newItemName) return;
    const newItem = {
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
                    <option value="SoundLighting">Sound & Lighting</option>
                    <option value="CateringPackage">Catering Package</option>
                    <option value="MarqueeTent">Marquee Tent</option>
                    <option value="PowerBackup">Power Backup</option>
                    <option value="Decor">Decor & Stage</option>
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

      {/* Resource Inventory Table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-200 bg-slate-50 flex items-center justify-between">
          <h3 className="font-bold text-slate-800 text-sm">Service & Equipment Packages</h3>
          <span className="text-xs text-slate-500">Live Inventory Sync</span>
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
            {resources.map(res => (
              <tr key={res.id} className="hover:bg-slate-50">
                <td className="px-6 py-4 font-semibold text-slate-900 flex items-center">
                  <Package className="w-4 h-4 mr-2 text-indigo-500" />
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
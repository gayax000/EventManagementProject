import React, { useState, useEffect } from 'react';
import { Package, Cpu, Check, Search, ShieldCheck, Phone } from 'lucide-react';
import { vendorService } from '../services/api';

export interface ResourceItem {
  id: string;
  name: string;
  type: string;
  unitPrice: number;
  available: number | string;
  isPartnerVendor?: boolean;
  vendorName?: string;
  contactNumber?: string;
}

export const ResourcesPage: React.FC = () => {
  const [partnerVendors, setPartnerVendors] = useState<ResourceItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState<string>('');

  const fetchVerifiedPartnerVendors = async () => {
    try {
      const vendorData = await vendorService.getVendors();
      if (Array.isArray(vendorData)) {
        const verified = vendorData.filter(v => 
          (v.verificationStatus || v.status) === 'Verified' &&
          Boolean(v.packageName) &&
          Number(v.packagePrice) > 0
        );
        const mappedVendors: ResourceItem[] = verified.map(v => {
          const category = v.category || 'General';
          const name = v.businessName || v.name;
          const pkgName = v.packageName || (v as any).packageName;
          const remarks = v.adminRemarks ? ` - ${v.adminRemarks}` : '';
          const displayName = pkgName ? `${name} - ${pkgName}` : (remarks ? `${name}${remarks}` : name);
          const pkgPrice = Number(v.packagePrice || (v as any).packagePrice) || 0;

          return {
            id: `v-res-${v.vendorId || v.id}`,
            name: displayName,
            type: category.includes('Catering') ? 'CateringPackage' : category,
            unitPrice: pkgPrice,
            available: 'Verified Partner',
            isPartnerVendor: true,
            vendorName: name,
            contactNumber: v.contactNumber || v.contact
          };
        });
        setPartnerVendors(mappedVendors);
      }
    } catch (err) {
      console.error("Failed to fetch partner vendors for resources catalog", err);
    }
  };

  useEffect(() => {
    fetchVerifiedPartnerVendors();
    const interval = setInterval(fetchVerifiedPartnerVendors, 5000);
    return () => clearInterval(interval);
  }, []);

  const categories = [
    { label: 'All Resources', value: 'All' },
    { label: 'Sound & Lighting', value: 'SoundLighting' },
    { label: 'Decor & Stage', value: 'Decor' },
    { label: 'Photography', value: 'Photography' },
    { label: 'Cakes', value: 'Cake' },
    { label: 'VIP Transport', value: 'Transport' },
    { label: 'Catering Buffets', value: 'CateringPackage' },
    { label: 'Tents & Safeguards', value: 'MarqueeTent' },
    { label: 'Power Backup', value: 'PowerBackup' },
  ];

  const filteredResources = partnerVendors.filter(res => {
    const resCatLower = (res.type || '').toLowerCase();
    const selectedLower = selectedCategory.toLowerCase();
    
    let matchesCategory = selectedCategory === 'All';
    if (!matchesCategory) {
      if (selectedLower.includes('cater')) matchesCategory = resCatLower.includes('cater');
      else if (selectedLower.includes('sound') || selectedLower.includes('light')) matchesCategory = resCatLower.includes('sound') || resCatLower.includes('light');
      else if (selectedLower.includes('decor')) matchesCategory = resCatLower.includes('decor');
      else if (selectedLower.includes('photo')) matchesCategory = resCatLower.includes('photo');
      else if (selectedLower.includes('cake')) matchesCategory = resCatLower.includes('cake');
      else if (selectedLower.includes('transport')) matchesCategory = resCatLower.includes('transport');
      else if (selectedLower.includes('tent')) matchesCategory = resCatLower.includes('tent');
      else if (selectedLower.includes('power')) matchesCategory = resCatLower.includes('power');
      else matchesCategory = resCatLower === selectedLower;
    }

    const matchesSearch = res.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          res.type.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          (res.vendorName || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Verified Vendor Catalog & Resource Packages</h1>
          <p className="text-slate-500 text-sm mt-1">
            Browse verified partner packages, equipment catalogs, and pricing tiers across service categories.
          </p>
        </div>
      </div>

      {/* Search & Category Filter Tabs */}
      <div className="mb-6 space-y-3">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
          <div className="relative w-full sm:w-80">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input 
              type="text"
              placeholder="Search resource, tier, or provider..."
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 text-xs bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm"
            />
          </div>
          <div className="flex items-center space-x-2 text-xs font-semibold text-slate-500">
            <span>Showing {filteredResources.length} of {partnerVendors.length} catalog items</span>
            <span className="text-purple-700 bg-purple-50 px-2.5 py-0.5 rounded-full border border-purple-200 font-bold">
              ({partnerVendors.length} Verified Partners)
            </span>
          </div>
        </div>

        {/* Category Pills without Emojis */}
        <div className="flex space-x-2 overflow-x-auto pb-2 scrollbar-none">
          {categories.map(cat => (
            <button
              key={cat.value}
              onClick={() => setSelectedCategory(cat.value)}
              className={`flex-shrink-0 px-3.5 py-1.5 rounded-lg text-xs font-semibold transition border ${
                selectedCategory === cat.value
                  ? 'bg-indigo-600 text-white border-indigo-600 shadow-sm'
                  : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>
      </div>

      {/* Resource Inventory Table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-200 bg-slate-50/80 flex items-center justify-between">
          <h3 className="font-bold text-slate-800 text-sm">Service & Equipment Packages</h3>
          <span className="text-xs text-slate-500 font-medium">Live Partner Sync ({filteredResources.length} Items)</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold">
              <tr>
                <th className="px-6 py-3.5">Package / Service Name</th>
                <th className="px-6 py-3.5">Category</th>
                <th className="px-6 py-3.5">Package Price</th>
                <th className="px-6 py-3.5">Verification</th>
                <th className="px-6 py-3.5 min-w-[280px]">Source & Provider Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 text-slate-700">
              {filteredResources.map(res => (
                <tr key={res.id} className="hover:bg-slate-50/80 transition bg-purple-50/5">
                  <td className="px-6 py-4 font-semibold text-slate-900">
                    <div className="flex items-center space-x-2.5">
                      <Package className="w-4 h-4 flex-shrink-0 text-purple-600" />
                      <span className="text-sm font-semibold text-slate-900">{res.name}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-xs font-medium px-2.5 py-1 bg-slate-100 rounded-md text-slate-700 border border-slate-200">
                      {res.type === 'CateringPackage' ? 'Catering' : res.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 font-bold text-slate-900 whitespace-nowrap">
                    Rs. {res.unitPrice.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-xs px-2.5 py-1 bg-purple-50 text-purple-700 border border-purple-200 rounded-full font-semibold inline-flex items-center shadow-2xs">
                      <ShieldCheck className="w-3.5 h-3.5 mr-1 text-purple-600" /> Certified Partner
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center space-x-2 flex-wrap gap-y-1">
                      <span className="text-xs text-slate-500 font-medium">Provider:</span>
                      <strong className="text-sm font-semibold text-slate-900">{res.vendorName}</strong>
                      {res.contactNumber && (
                        <span className="inline-flex items-center text-slate-700 bg-slate-100 px-2 py-0.5 rounded text-[11.5px] font-mono font-medium border border-slate-200 whitespace-nowrap">
                          <Phone className="w-3 h-3 text-slate-500 mr-1 flex-shrink-0" />
                          {res.contactNumber}
                        </span>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
              {filteredResources.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-slate-400 text-sm">
                    No resource packages found matching your criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
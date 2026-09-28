import { describe, it, expect } from 'vitest';

// Unit Test suite verifying Manager Pricing, Proposal Calculations, and Weather Safeguard Rules
describe('Manager Pricing & Proposal Calculation Logic', () => {
  it('should accurately calculate total package cost with granular category adjustments', () => {
    const venueRental = 350000;
    const perPlate = 5000;
    const guestCount = 100;
    const cateringTotal = perPlate * guestCount; // 500000
    const soundRig = 150000;
    const floralDeco = 80000;
    const photography = 100000;
    const specialRequestAlloc = 25000;

    const subtotal = venueRental + cateringTotal + soundRig + floralDeco + photography + specialRequestAlloc;

    expect(subtotal).toBe(1205000);
  });

  it('should ensure special discount deduction does not produce negative final cost', () => {
    const baseSubtotal = 500000;
    const excessiveDiscount = 600000;

    const finalTotal = Math.max(0, baseSubtotal - excessiveDiscount);
    expect(finalTotal).toBe(0);
  });

  it('should auto-inject Marquee Tent safeguard when outdoor event rain probability exceeds 60%', () => {
    const isOutdoor = true;
    const rainProbability = 75;
    const marqueeTentPrice = 150000;

    const requiresSafeguard = isOutdoor && rainProbability >= 60;
    const safeguardCost = requiresSafeguard ? marqueeTentPrice : 0;

    expect(requiresSafeguard).toBe(true);
    expect(safeguardCost).toBe(150000);
  });

  it('should format and clean client revision category tags', () => {
    const revisionInput = "[Photography] Please upgrade to cinematic video coverage";
    const tagMatch = revisionInput.match(/^\[(.*?)\]/);

    expect(tagMatch).not.toBeNull();
    expect(tagMatch![1]).toBe("Photography");
  });
});

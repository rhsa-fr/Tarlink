// Tarlink Core Booking Rules (Server-side Business Logic)
// Financial calculations (DP 20%, fee 8%, zone transport, haversine, anti-bocor phone masking)

export interface BookingFinancials {
  totalPrice: number;
  dpPercent: number;
  dpAmount: number;
  remainingAmount: number;
  platformFeePct: number;
  platformFee: number;
  netPayout: number;
}

/**
 * Haversine formula to compute great-circle distance between two GPS coordinates in kilometers.
 */
export function calculateHaversineKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const R = 6371; // Radius of Earth in KM
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 100) / 100;
}

/**
 * Maps travel distance to official Tarlink logistics ring.
 * - Ring 1 (<= 15 km): Free / Included
 * - Ring 2 (15.1 - 35 km): Local transport addition
 * - Ring 3 (> 35 km): Inter-district / long distance addition
 */
export function determineZone(distanceKm: number): "Ring 1" | "Ring 2" | "Ring 3" {
  if (distanceKm <= 15) return "Ring 1";
  if (distanceKm <= 35) return "Ring 2";
  return "Ring 3";
}

/**
 * Calculates standard Tarlink financials:
 * - Total Price = Package Base + Zone Logistics Extra
 * - DP = 20% of Total Price
 * - Remaining = 80% (Paid cash on-site to group leader)
 * - Platform Fee = 8% of Total Price (deducted from online DP before disbursement)
 * - Net Payout = DP Amount - Platform Fee (Disbursed to group leader on H+2)
 */
export function calculateBookingFinancials(
  packageBasePrice: number,
  zoneExtraPrice: number
): BookingFinancials {
  const totalPrice = Math.round(packageBasePrice + zoneExtraPrice);
  const dpPercent = 20;
  const dpAmount = Math.round((totalPrice * dpPercent) / 100);
  const remainingAmount = totalPrice - dpAmount;
  const platformFeePct = 8;
  const platformFee = Math.round((totalPrice * platformFeePct) / 100);
  const netPayout = dpAmount - platformFee;

  return {
    totalPrice,
    dpPercent,
    dpAmount,
    remainingAmount,
    platformFeePct,
    platformFee,
    netPayout,
  };
}

/**
 * Anti-Bocor: Masks sensitive phone number in public catalogs.
 * Formats 081234567890 -> 0812-****-**90
 */
export function maskPhoneNumber(phone: string): string {
  if (!phone || phone.length < 10) {
    return "08**-****-**";
  }
  const prefix = phone.substring(0, 4);
  const suffix = phone.slice(-2);
  return `${prefix}-****-**${suffix}`;
}

/**
 * Anti-PHP: Prevents customers from holding group calendars maliciously.
 * Customer may have at most 2 PENDING custom negotiation bookings simultaneously.
 */
export function validateCustomBookingLimit(pendingCount: number): boolean {
  return pendingCount < 2;
}

/**
 * Anti Double-Booking: Guarantees 1 group has only 1 active booking per date.
 */
export function isGroupAvailableOnDate(
  targetDate: string,
  occupiedDates: string[]
): boolean {
  return !occupiedDates.includes(targetDate);
}

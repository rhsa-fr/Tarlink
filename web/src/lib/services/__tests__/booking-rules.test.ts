import { describe, it, expect } from "vitest";
import {
  calculateHaversineKm,
  determineZone,
  calculateBookingFinancials,
  maskPhoneNumber,
  validateCustomBookingLimit,
  isGroupAvailableOnDate,
} from "../booking-rules";

describe("Tarlink Core Booking Rules (TDD)", () => {
  describe("Haversine Distance & Zone Determination", () => {
    it("calculates accurate distance between coordinates in KM", () => {
      // Indramayu city center (-6.3263, 108.3200) to Jatibarang (-6.4716, 108.3108) ~ 16.2 km
      const distance = calculateHaversineKm(-6.3263, 108.3200, -6.4716, 108.3108);
      expect(distance).toBeGreaterThan(15);
      expect(distance).toBeLessThan(18);
    });

    it("assigns correct zone based on distance", () => {
      expect(determineZone(5)).toBe("Ring 1");
      expect(determineZone(15)).toBe("Ring 1");
      expect(determineZone(15.1)).toBe("Ring 2");
      expect(determineZone(35)).toBe("Ring 2");
      expect(determineZone(35.1)).toBe("Ring 3");
      expect(determineZone(80)).toBe("Ring 3");
    });
  });

  describe("Booking Financials (DP 20% & Fee 8%)", () => {
    it("calculates correct DP, remaining, and platform fee", () => {
      const packagePrice = 25_000_000; // Rp 25jt
      const zoneExtraPrice = 1_500_000; // Rp 1.5jt

      const result = calculateBookingFinancials(packagePrice, zoneExtraPrice);

      expect(result.totalPrice).toBe(26_500_000);
      expect(result.dpPercent).toBe(20);
      expect(result.dpAmount).toBe(5_300_000); // 20% of 26.5jt
      expect(result.remainingAmount).toBe(21_200_000); // 80% of 26.5jt
      expect(result.platformFeePct).toBe(8);
      expect(result.platformFee).toBe(2_120_000); // 8% of 26.5jt
      expect(result.netPayout).toBe(3_180_000); // DP (5.3jt) - Fee (2.12jt) = 3.18jt disburse H+2
    });
  });

  describe("Phone Number Masking (Anti-Bocor Platform)", () => {
    it("masks phone numbers correctly for public viewing", () => {
      expect(maskPhoneNumber("081234567890")).toBe("0812-****-**90");
      expect(maskPhoneNumber("085299887766")).toBe("0852-****-**66");
    });

    it("handles short or invalid numbers gracefully", () => {
      expect(maskPhoneNumber("0812")).toBe("08**-****-**");
      expect(maskPhoneNumber("")).toBe("08**-****-**");
    });
  });

  describe("Anti-PHP Limit (Max 2 Pending Custom Bookings)", () => {
    it("allows booking if active pending count is under 2", () => {
      expect(validateCustomBookingLimit(0)).toBe(true);
      expect(validateCustomBookingLimit(1)).toBe(true);
    });

    it("rejects booking if active pending count is 2 or more", () => {
      expect(validateCustomBookingLimit(2)).toBe(false);
      expect(validateCustomBookingLimit(3)).toBe(false);
    });
  });

  describe("Anti Double-Booking Check (Fullday Mutlak)", () => {
    it("allows booking if date is not occupied by active job", () => {
      const activeBookedDates = ["2026-10-15", "2026-10-20"];
      expect(isGroupAvailableOnDate("2026-10-16", activeBookedDates)).toBe(true);
    });

    it("rejects booking if group already has active booking on date", () => {
      const activeBookedDates = ["2026-10-15", "2026-10-20"];
      expect(isGroupAvailableOnDate("2026-10-15", activeBookedDates)).toBe(false);
    });
  });
});

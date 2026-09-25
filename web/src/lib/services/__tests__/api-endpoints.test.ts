import { describe, it, expect } from "vitest";
import { TarlinkStore } from "../tarlink-store";

describe("Tarlink REST API Store & Logic Integration Tests", () => {
  it("retrieves catalog with masked phone numbers", async () => {
    const catalog = await TarlinkStore.getCatalog();
    expect(catalog.length).toBeGreaterThan(0);
    for (const artist of catalog) {
      expect(artist.masked_phone).toBeDefined();
      expect(artist.masked_phone).toMatch(/^\d{4}-\*{4}-\*\*\d{2}$/);
    }
  });

  it("retrieves artist detail with packages", async () => {
    const artist = await TarlinkStore.getArtistDetail("a1111111-1111-4111-a111-111111111111");
    expect(artist).not.toBeNull();
    expect(artist?.display_name).toBe("Sandiwara Dharma Kudeta");
    expect(artist?.packages.length).toBeGreaterThan(0);
  });

  it("creates a booking with accurate Haversine distance, zone, and DP 20%", async () => {
    const booking = await TarlinkStore.createBooking({
      customer_id: "c-test-1",
      artist_id: "a1111111-1111-4111-a111-111111111111",
      package_id: "p1",
      event_date: "2026-11-20",
      venue_address: "Desa Karangampel, Blok Masjid",
      city: "Indramayu",
      district: "Karangampel",
      venue_lat: -6.4633,
      venue_lng: 108.4502,
    });

    expect(booking.code).toMatch(/^TRG-2026-\d{4}$/);
    expect(booking.dp_percent).toBe(20);
    expect(booking.dp_amount).toBeGreaterThan(0);
    expect(booking.remaining_amount).toBe(booking.total_price - booking.dp_amount);
    expect(booking.status).toBe("WAITING_DP");
  });

  it("rejects double booking on the same date for the same artist", async () => {
    // b1-trg-0041 is on 2026-09-25 for a1111111-1111-4111-a111-111111111111 with DP_PAID
    await expect(
      TarlinkStore.createBooking({
        customer_id: "c-test-2",
        artist_id: "a1111111-1111-4111-a111-111111111111",
        package_id: "p1",
        event_date: "2026-09-25",
        venue_address: "Desa Eretan",
        city: "Indramayu",
        district: "Kandanghaur",
        venue_lat: -6.3401,
        venue_lng: 108.1205,
      })
    ).rejects.toThrow("Grup sudah memiliki jadwal manggung di tanggal tersebut");
  });

  it("handles Midtrans payment webhook and sets status to DP_PAID", async () => {
    const result = await TarlinkStore.handleMidtransWebhook({
      order_id: "TRG-2026-0041",
      transaction_status: "settlement",
      gross_amount: "6000000",
    });

    expect(result.status).toBe("success");
    expect(result.booking_status).toBe("DP_PAID");
  });

  it("returns admin overview stats with 8% platform fee calculation", async () => {
    const stats = await TarlinkStore.getAdminStats();
    expect(stats.totalBookings).toBeGreaterThan(0);
    expect(stats.gmv).toBeGreaterThan(0);
    expect(stats.platformRevenue).toBe(Math.round((stats.gmv * 8) / 100));
  });

  it("allows admin to approve pending stall verification", async () => {
    const pendings = await TarlinkStore.getPendingVerifications();
    expect(pendings.length).toBeGreaterThan(0);

    const approved = await TarlinkStore.updateArtistStatus(pendings[0].id, "verified");
    expect(approved.status).toBe("verified");
  });
});

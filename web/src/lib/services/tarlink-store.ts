import { getSupabaseServerClient } from "../supabase-server";
import {
  calculateHaversineKm,
  determineZone,
  calculateBookingFinancials,
  maskPhoneNumber,
  validateCustomBookingLimit,
  isGroupAvailableOnDate,
} from "./booking-rules";

export interface ArtistRecord {
  id: string;
  user_id: string;
  display_name: string;
  category: string;
  base_city: string;
  base_district: string;
  base_lat: number;
  base_lng: number;
  coverage_cities: string[];
  description: string;
  auto_accept: boolean;
  price_min: number;
  price_max: number;
  rating_avg: number;
  total_job: number;
  video_urls: string[];
  status: "pending" | "verified" | "suspended";
  bank_name?: string;
  bank_no?: string;
  bank_owner?: string;
  ktp_url?: string;
  phone?: string;
  avatar_url?: string;
  masked_phone?: string;
}

export interface PackageRecord {
  id: string;
  artist_id: string;
  name: string;
  duration_hours: number;
  price: number;
  includes: string;
  is_active: boolean;
}

export interface PortfolioRecord {
  id: string;
  artist_id: string;
  type: string;
  url: string;
  title: string;
}

export interface BookingRecord {
  id: string;
  code: string;
  customer_id: string;
  artist_id: string;
  package_id: string;
  event_date: string;
  venue_address: string;
  city: string;
  district: string;
  venue_lat: number;
  venue_lng: number;
  distance_km: number;
  zone: string;
  total_price: number;
  dp_percent: number;
  dp_amount: number;
  remaining_amount: number;
  booking_type: "instant" | "custom";
  status:
    | "PENDING"
    | "APPROVED"
    | "WAITING_DP"
    | "DP_PAID"
    | "PARTIAL_PAID"
    | "FULL_PAID"
    | "ONGOING"
    | "COMPLETED"
    | "CANCELLED"
    | "REFUNDED"
    | "EXPIRED";
  note?: string;
  created_at: string;
  artist_name?: string;
  customer_name?: string;
  customer_phone?: string;
}

export interface PayoutRecord {
  id: string;
  booking_id: string;
  artist_id: string;
  gross: number;
  fee_pct: number;
  fee: number;
  net: number;
  status: "HOLD" | "READY" | "PROCESSING" | "COMPLETED" | "FAILED" | "DISPUTED";
  disbursement_id?: string;
  artist_name?: string;
  bank_name?: string;
  bank_no?: string;
  bank_owner?: string;
  created_at: string;
}

export interface DisputeRecord {
  id: string;
  booking_id: string;
  reporter_id: string;
  reporter_name: string;
  reporter_phone: string;
  artist_name: string;
  booking_code: string;
  reason: string;
  evidence_urls: string[];
  status: "open" | "under_review" | "resolved" | "rejected";
  verdict?: string;
  created_at: string;
}

// Seed datasets matching Pantura regional artists
const MEMORY_ARTISTS: ArtistRecord[] = [
  {
    id: "a1111111-1111-4111-a111-111111111111",
    user_id: "11111111-1111-4111-a111-111111111111",
    display_name: "Sandiwara Dharma Kudeta",
    category: "sandiwara-full",
    base_city: "Indramayu",
    base_district: "Kandanghaur",
    base_lat: -6.3768,
    base_lng: 108.1568,
    coverage_cities: ["Indramayu", "Cirebon", "Subang", "Majalengka"],
    description: "Grup sandiwara legendaris Pantura pimpinan H. Waryono dengan lakon klasik dan panggung megah.",
    auto_accept: true,
    price_min: 25000000,
    price_max: 35000000,
    rating_avg: 4.9,
    total_job: 124,
    video_urls: ["https://youtube.com/watch?v=mock-dharma-1"],
    status: "verified",
    bank_name: "BCA",
    bank_no: "1234567890",
    bank_owner: "H. Waryono",
    phone: "081234567801",
    avatar_url: "https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=800&auto=format&fit=crop&q=80",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/waryono_ktp.jpg",
  },
  {
    id: "a2222222-2222-4222-a222-222222222222",
    user_id: "22222222-2222-4222-a222-222222222222",
    display_name: "Sandiwara Candra Kirana",
    category: "sandiwara-full",
    base_city: "Cirebon",
    base_district: "Gegesik",
    base_lat: -6.5898,
    base_lng: 108.4735,
    coverage_cities: ["Cirebon", "Indramayu", "Majalengka", "Kuningan"],
    description: "Sandiwara gaya Cirebonan dengan gamelan degung klasik dan tata lampu panggung modern.",
    auto_accept: false,
    price_min: 22000000,
    price_max: 30000000,
    rating_avg: 4.8,
    total_job: 98,
    video_urls: ["https://youtube.com/watch?v=mock-candra-1"],
    status: "verified",
    bank_name: "BRI",
    bank_no: "002233445566",
    bank_owner: "Dalang Supriyadi",
    phone: "081234567802",
    avatar_url: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/supriyadi_ktp.jpg",
  },
  {
    id: "a3333333-3333-4333-a333-333333333333",
    user_id: "33333333-3333-4333-a333-333333333333",
    display_name: "Tarling Dangdut Hj. Dewi Kirana",
    category: "tarling-dangdut",
    base_city: "Indramayu",
    base_district: "Jatibarang",
    base_lat: -6.4716,
    base_lng: 108.3108,
    coverage_cities: ["Indramayu", "Cirebon", "Subang"],
    description: "Ratu Tarling Pantura dengan aransemen dangdut modern koplo dan sound system menggelegar.",
    auto_accept: true,
    price_min: 15000000,
    price_max: 22000000,
    rating_avg: 5.0,
    total_job: 215,
    video_urls: ["https://youtube.com/watch?v=mock-dewi-1"],
    status: "verified",
    bank_name: "BCA",
    bank_no: "9988776655",
    bank_owner: "Hj. Dewi Kirana",
    phone: "081234567803",
    avatar_url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/dewi_ktp.jpg",
  },
  {
    id: "a4444444-4444-4444-a444-444444444444",
    user_id: "44444444-4444-4444-a444-444444444444",
    display_name: "Organ Tunggal Rolani Diva",
    category: "organ-tunggal",
    base_city: "Cirebon",
    base_district: "Palimanan",
    base_lat: -6.7025,
    base_lng: 108.4317,
    coverage_cities: ["Cirebon", "Majalengka", "Indramayu"],
    description: "Hiburan hajatan praktis, 2 biduan hits Pantura, sound 5000 watt jernih.",
    auto_accept: true,
    price_min: 4500000,
    price_max: 7500000,
    rating_avg: 4.7,
    total_job: 85,
    video_urls: [],
    status: "verified",
    bank_name: "Mandiri",
    bank_no: "1310022334455",
    bank_owner: "Mas Rolani",
    phone: "081234567804",
    avatar_url: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/rolani_ktp.jpg",
  },
  {
    id: "a5555555-5555-4555-a555-555555555555",
    user_id: "55555555-5555-4555-a555-555555555555",
    display_name: "Sindy Puspita (Biduan & MC)",
    category: "biduan-solo",
    base_city: "Indramayu",
    base_district: "Sindang",
    base_lat: -6.3355,
    base_lng: 108.3182,
    coverage_cities: ["Indramayu", "Cirebon"],
    description: "Biduan solo dan MC pranata cara adat Sunda / Cirebonan.",
    auto_accept: false,
    price_min: 2500000,
    price_max: 4500000,
    rating_avg: 4.9,
    total_job: 64,
    video_urls: [],
    status: "verified",
    bank_name: "BCA",
    bank_no: "5544332211",
    bank_owner: "Sindy Puspita",
    phone: "081234567805",
    avatar_url: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/sindy_ktp.jpg",
  },
  {
    id: "a6666666-6666-4666-a666-666666666666",
    user_id: "66666666-6666-4666-a666-666666666666",
    display_name: "Sandiwara Jaya Baya Pantura",
    category: "sandiwara-full",
    base_city: "Indramayu",
    base_district: "Haurgeulis",
    base_lat: -6.4589,
    base_lng: 107.9712,
    coverage_cities: ["Indramayu", "Subang"],
    description: "Lapak baru sandiwara generasi muda Haurgeulis. Menunggu verifikasi KTP admin.",
    auto_accept: false,
    price_min: 20000000,
    price_max: 28000000,
    rating_avg: 0.0,
    total_job: 0,
    video_urls: [],
    status: "pending",
    bank_name: "BJB",
    bank_no: "010203040506",
    bank_owner: "Tatang Kuswandi",
    phone: "081234567809",
    ktp_url: "https://mock-tarlingbook.supabase.co/storage/v1/object/public/ktp-verifications/tatang_ktp.jpg",
  },
];

const MEMORY_PACKAGES: PackageRecord[] = [
  {
    id: "p1",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    name: "Paket Fullday Panggung Siang & Malam (2 Babak)",
    duration_hours: 14,
    price: 30000000,
    includes: "Panggung 12x8m, Tata Suara 15.000W, Genset 60kVA, 45 Personel, Lakon Pilihan",
    is_active: true,
  },
  {
    id: "p2",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    name: "Paket Malam Utama (1 Babak)",
    duration_hours: 7,
    price: 25000000,
    includes: "Panggung 10x8m, Tata Suara 10.000W, Genset, 35 Personel",
    is_active: true,
  },
  {
    id: "p3",
    artist_id: "a3333333-3333-4333-a333-333333333333",
    name: "Paket Dangdut Pesta Hajatan Komplit",
    duration_hours: 10,
    price: 20000000,
    includes: "Hj. Dewi Kirana Full Live, 4 Biduan Pengiring, Sound Line Array, Panggung Semi Rigging",
    is_active: true,
  },
  {
    id: "p4",
    artist_id: "a4444444-4444-4444-a444-444444444444",
    name: "Paket Organ Tunggal Reguler",
    duration_hours: 8,
    price: 5500000,
    includes: "Keyboardist, 2 Biduan, Sound System 5.000W, Operator Suara",
    is_active: true,
  },
];

const MEMORY_PORTFOLIOS: PortfolioRecord[] = [
  {
    id: "port-1",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    type: "image",
    url: "https://images.unsplash.com/photo-1469488865564-c2de10f69f96?w=800&auto=format&fit=crop&q=80",
    title: "Pentas Akbar Lapangan Kandanghaur",
  },
  {
    id: "port-2",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    type: "image",
    url: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80",
    title: "Busana Klasik Wayang Wong Pantura",
  },
  {
    id: "port-3",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    type: "image",
    url: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80",
    title: "Tata Lampu & Panggung Terop Megah",
  },
  {
    id: "port-4",
    artist_id: "a2222222-2222-4222-a222-222222222222",
    type: "image",
    url: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&auto=format&fit=crop&q=80",
    title: "Nayaga Gamelan Slendro",
  },
  {
    id: "port-5",
    artist_id: "a3333333-3333-4333-a333-333333333333",
    type: "image",
    url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80",
    title: "Aksi Panggung Ratu Tarling Pantura",
  },
  {
    id: "port-6",
    artist_id: "a4444444-4444-4444-a444-444444444444",
    type: "image",
    url: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80",
    title: "Keyboard Virtuoso Performance",
  },
  {
    id: "port-7",
    artist_id: "a5555555-5555-4555-a555-555555555555",
    type: "image",
    url: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800&auto=format&fit=crop&q=80",
    title: "Penampilan Spesial Resepsi Pengantin",
  },
];

const MEMORY_BOOKINGS: BookingRecord[] = [
  {
    id: "b1-trg-0041",
    code: "TRG-2026-0041",
    customer_id: "c1-user-hajat",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    package_id: "p1",
    event_date: "2026-09-25",
    venue_address: "Blok Karanganyar RT 04 RW 02, Desa Eretan Wetan",
    city: "Indramayu",
    district: "Kandanghaur",
    venue_lat: -6.3401,
    venue_lng: 108.1205,
    distance_km: 5.8,
    zone: "Ring 1",
    total_price: 30000000,
    dp_percent: 20,
    dp_amount: 6000000,
    remaining_amount: 24000000,
    booking_type: "instant",
    status: "DP_PAID",
    created_at: "2026-09-18T10:00:00Z",
    artist_name: "Sandiwara Dharma Kudeta",
    customer_name: "Ibu Hj. Aminah (Shohibul Hajat)",
    customer_phone: "081399887711",
  },
  {
    id: "b2-trg-0042",
    code: "TRG-2026-0042",
    customer_id: "c2-user-hajat",
    artist_id: "a3333333-3333-4333-a333-333333333333",
    package_id: "p3",
    event_date: "2026-09-15",
    venue_address: "Jl. Raya Jatibarang Timur No. 45",
    city: "Indramayu",
    district: "Jatibarang",
    venue_lat: -6.4716,
    venue_lng: 108.3108,
    distance_km: 2.1,
    zone: "Ring 1",
    total_price: 20000000,
    dp_percent: 20,
    dp_amount: 4000000,
    remaining_amount: 16000000,
    booking_type: "instant",
    status: "COMPLETED",
    created_at: "2026-09-10T08:00:00Z",
    artist_name: "Tarling Dangdut Hj. Dewi Kirana",
    customer_name: "Bapak H. Raswan",
    customer_phone: "081288776655",
  },
];

const MEMORY_PAYOUTS: PayoutRecord[] = [
  {
    id: "pay-1",
    booking_id: "b2-trg-0042",
    artist_id: "a3333333-3333-4333-a333-333333333333",
    gross: 4000000,
    fee_pct: 8,
    fee: 1600000,
    net: 2400000,
    status: "READY",
    artist_name: "Tarling Dangdut Hj. Dewi Kirana",
    bank_name: "BCA",
    bank_no: "9988776655",
    bank_owner: "Hj. Dewi Kirana",
    created_at: "2026-09-16T10:00:00Z",
  },
  {
    id: "pay-2",
    booking_id: "b1-trg-0041",
    artist_id: "a1111111-1111-4111-a111-111111111111",
    gross: 6000000,
    fee_pct: 8,
    fee: 2400000,
    net: 3600000,
    status: "HOLD",
    artist_name: "Sandiwara Dharma Kudeta",
    bank_name: "BCA",
    bank_no: "1234567890",
    bank_owner: "H. Waryono",
    created_at: "2026-09-18T10:05:00Z",
  },
];

const MEMORY_DISPUTES: DisputeRecord[] = [
  {
    id: "disp-1",
    booking_id: "b-disp-88",
    reporter_id: "c-user-99",
    reporter_name: "Ibu Titin Sumiati",
    reporter_phone: "081299334411",
    artist_name: "Organ Tunggal Pantura Mini",
    booking_code: "TRG-2026-0038",
    reason: "Penyanyi telat datang 3 jam dari jadwal kesepakatan dan lagu yang dibawakan tidak sesuai request hajat.",
    evidence_urls: [
      "https://mock-tarlingbook.supabase.co/storage/v1/object/public/dispute-evidences/bukti1.jpg",
    ],
    status: "open",
    created_at: "2026-09-17T14:30:00Z",
  },
];

export class TarlinkStore {
  /**
   * Retrieves verified artists for catalog with phone masking and sensitive data sanitized.
   */
  static async getCatalog(city?: string, category?: string): Promise<ArtistRecord[]> {
    try {
      const supabase = getSupabaseServerClient();
      let query = supabase.from("artist_profiles").select("*");
      if (city) query = query.ilike("base_city", city);
      if (category) query = query.eq("category", category);
      query = query.eq("status", "verified");

      const { data, error } = await query;
      if (!error && data && data.length > 0) {
        return data.map((a: any) => {
          const { bank_no, bank_owner, ktp_url, ...safe } = a;
          return {
            ...safe,
            masked_phone: maskPhoneNumber(a.phone || "081234567800"),
          };
        }) as ArtistRecord[];
      }
    } catch {
      // fallback to memory
    }

    let results = MEMORY_ARTISTS.filter((a) => a.status === "verified");
    if (city) {
      results = results.filter((a) => a.base_city.toLowerCase() === city.toLowerCase());
    }
    if (category) {
      results = results.filter((a) => a.category === category);
    }

    return results.map((a) => {
      const { bank_no, bank_owner, ktp_url, ...safe } = a;
      return {
        ...safe,
        masked_phone: maskPhoneNumber(a.phone || "081234567800"),
      };
    });
  }

  /**
   * Get artist detail with full info, portfolios, packages, and sensitive data sanitized
   */
  static async getArtistDetail(id: string) {
    try {
      const supabase = getSupabaseServerClient();
      const { data: artist, error } = await supabase
        .from("artist_profiles")
        .select("*")
        .eq("id", id)
        .single();
      if (!error && artist) {
        const { data: packages } = await supabase
          .from("packages")
          .select("*")
          .eq("artist_id", id)
          .eq("is_active", true);
        const { data: portfolios } = await supabase
          .from("portfolios")
          .select("*")
          .eq("artist_id", id);
        const { bank_no, bank_owner, ktp_url, ...safeArtist } = artist;
        return {
          ...safeArtist,
          masked_phone: maskPhoneNumber(artist.phone || ""),
          packages: packages || [],
          portfolios: portfolios || [],
        };
      }
    } catch {
      // fallback to memory
    }

    const artist = MEMORY_ARTISTS.find((a) => a.id === id);
    if (!artist) return null;

    const packages = MEMORY_PACKAGES.filter((p) => p.artist_id === id);
    const portfolios = MEMORY_PORTFOLIOS.filter((p) => p.artist_id === id);
    const { bank_no, bank_owner, ktp_url, ...safeArtist } = artist;
    return {
      ...safeArtist,
      masked_phone: maskPhoneNumber(artist.phone || ""),
      packages,
      portfolios,
    };
  }

  /**
   * Creates a new booking with Haversine, Anti Double-booking, and financial calculations.
   */
  static async createBooking(payload: {
    customer_id: string;
    artist_id: string;
    package_id: string;
    event_date: string;
    venue_address: string;
    city: string;
    district: string;
    venue_lat: number;
    venue_lng: number;
    booking_type?: "instant" | "custom";
    note?: string;
    customer_name?: string;
    customer_phone?: string;
  }) {
    let artist = MEMORY_ARTISTS.find((a) => a.id === payload.artist_id);
    let pkg = MEMORY_PACKAGES.find((p) => p.id === payload.package_id);

    try {
      const supabase = getSupabaseServerClient();
      if (!artist) {
        const { data: dbArtist } = await supabase
          .from("artist_profiles")
          .select("*")
          .eq("id", payload.artist_id)
          .single();
        if (dbArtist) artist = dbArtist;
      }
      if (!pkg) {
        const { data: dbPkg } = await supabase
          .from("packages")
          .select("*")
          .eq("id", payload.package_id)
          .single();
        if (dbPkg) pkg = dbPkg;
      }
    } catch {}

    if (!artist) {
      throw new Error("Grup seni tidak ditemukan");
    }

    if (!pkg) {
      throw new Error("Paket panggung tidak ditemukan");
    }

    // 1. Anti-PHP limit check
    if (payload.booking_type === "custom") {
      let activePending = MEMORY_BOOKINGS.filter(
        (b) =>
          b.customer_id === payload.customer_id &&
          b.booking_type === "custom" &&
          b.status === "PENDING"
      ).length;

      try {
        const supabase = getSupabaseServerClient();
        const { count } = await supabase
          .from("bookings")
          .select("*", { count: "exact", head: true })
          .eq("customer_id", payload.customer_id)
          .eq("booking_type", "custom")
          .eq("status", "PENDING");
        if (typeof count === "number") {
          activePending = Math.max(activePending, count);
        }
      } catch {}

      if (!validateCustomBookingLimit(activePending)) {
        throw new Error(
          "Batas maksimal 2 pemesanan kustom berstatus PENDING telah tercapai"
        );
      }
    }

    // 2. Anti Double-booking check
    const occupiedDates = new Set(
      MEMORY_BOOKINGS.filter(
        (b) =>
          b.artist_id === payload.artist_id &&
          ["DP_PAID", "PARTIAL_PAID", "FULL_PAID", "ONGOING"].includes(b.status)
      ).map((b) => b.event_date)
    );

    try {
      const supabase = getSupabaseServerClient();
      const { data: dbBookings } = await supabase
        .from("bookings")
        .select("event_date, status")
        .eq("artist_id", payload.artist_id)
        .in("status", ["DP_PAID", "PARTIAL_PAID", "FULL_PAID", "ONGOING"]);

      if (dbBookings) {
        dbBookings.forEach((b: any) => occupiedDates.add(b.event_date));
      }
    } catch {}

    if (!isGroupAvailableOnDate(payload.event_date, Array.from(occupiedDates))) {
      throw new Error("Grup sudah memiliki jadwal manggung di tanggal tersebut");
    }

    // 3. Haversine distance & zone
    const distanceKm = calculateHaversineKm(
      artist.base_lat,
      artist.base_lng,
      payload.venue_lat,
      payload.venue_lng
    );
    const zone = determineZone(distanceKm);

    let zoneExtra = 0;
    if (zone === "Ring 2") zoneExtra = 1000000;
    if (zone === "Ring 3") zoneExtra = 2500000;

    const financials = calculateBookingFinancials(pkg.price, zoneExtra);
    const code = `TRG-2026-${String(MEMORY_BOOKINGS.length + 42).padStart(4, "0")}`;

    const newBooking: BookingRecord = {
      id: `b-${Date.now()}`,
      code,
      customer_id: payload.customer_id,
      artist_id: payload.artist_id,
      package_id: payload.package_id,
      event_date: payload.event_date,
      venue_address: payload.venue_address,
      city: payload.city,
      district: payload.district,
      venue_lat: payload.venue_lat,
      venue_lng: payload.venue_lng,
      distance_km: distanceKm,
      zone,
      total_price: financials.totalPrice,
      dp_percent: financials.dpPercent,
      dp_amount: financials.dpAmount,
      remaining_amount: financials.remainingAmount,
      booking_type: payload.booking_type || "instant",
      status: "WAITING_DP",
      note: payload.note,
      created_at: new Date().toISOString(),
      artist_name: artist.display_name,
      customer_name: payload.customer_name || "Shohibul Hajat",
      customer_phone: payload.customer_phone || "081234567890",
    };

    MEMORY_BOOKINGS.unshift(newBooking);

    // Persist to Supabase Database
    try {
      const supabase = getSupabaseServerClient();
      await supabase.from("bookings").insert({
        id: newBooking.id,
        code: newBooking.code,
        customer_id: newBooking.customer_id,
        artist_id: newBooking.artist_id,
        package_id: newBooking.package_id,
        event_date: newBooking.event_date,
        venue_address: newBooking.venue_address,
        city: newBooking.city,
        district: newBooking.district,
        venue_lat: newBooking.venue_lat,
        venue_lng: newBooking.venue_lng,
        total_price: newBooking.total_price,
        dp_amount: newBooking.dp_amount,
        remaining_amount: newBooking.remaining_amount,
        status: newBooking.status,
      });
    } catch {
      // safe fallback
    }

    // Create payout record with status HOLD
    const newPayout: PayoutRecord = {
      id: `pay-${Date.now()}`,
      booking_id: newBooking.id,
      artist_id: artist.id,
      gross: financials.dpAmount,
      fee_pct: financials.platformFeePct,
      fee: financials.platformFee,
      net: financials.netPayout,
      status: "HOLD",
      artist_name: artist.display_name,
      bank_name: artist.bank_name || "BCA",
      bank_no: artist.bank_no || "000000",
      bank_owner: artist.bank_owner || artist.display_name,
      created_at: new Date().toISOString(),
    };
    MEMORY_PAYOUTS.unshift(newPayout);

    return newBooking;
  }

  /**
   * Process idempotent Midtrans payment webhook
   */
  static async handleMidtransWebhook(payload: {
    order_id: string;
    transaction_status: string;
    gross_amount: string;
  }) {
    let booking = MEMORY_BOOKINGS.find((b) => b.code === payload.order_id);
    let supabaseBooking: any = null;

    if (!booking) {
      try {
        const supabase = getSupabaseServerClient();
        const { data } = await supabase
          .from("bookings")
          .select("*")
          .eq("code", payload.order_id)
          .single();
        if (data) {
          supabaseBooking = data;
        }
      } catch {}
    }

    if (!booking && !supabaseBooking) {
      return { status: "not_found", message: "Booking code not found" };
    }

    if (
      payload.transaction_status === "capture" ||
      payload.transaction_status === "settlement"
    ) {
      if (booking) booking.status = "DP_PAID";

      try {
        const supabase = getSupabaseServerClient();
        await supabase
          .from("bookings")
          .update({ status: "DP_PAID" })
          .eq("code", payload.order_id);
      } catch {}

      const bookingId = booking?.id || supabaseBooking?.id;
      // Mark associated payout ready for H+2
      const payout = MEMORY_PAYOUTS.find((p) => p.booking_id === bookingId);
      if (payout) {
        payout.status = "HOLD"; // Will become READY after COMPLETED
      }

      try {
        const supabase = getSupabaseServerClient();
        await supabase
          .from("payouts")
          .update({ status: "HOLD" })
          .eq("booking_id", bookingId);
      } catch {}

      return { status: "success", booking_status: "DP_PAID" };
    }

    return { status: "ignored", transaction_status: payload.transaction_status };
  }

  /**
   * Admin: Get comprehensive dashboard market metrics
   */
  static async getAdminStats() {
    const totalBookings = MEMORY_BOOKINGS.length;
    const gmv = MEMORY_BOOKINGS.reduce((sum, b) => sum + b.total_price, 0);
    const platformRevenue = Math.round((gmv * 8) / 100);
    const activeJobs = MEMORY_BOOKINGS.filter((b) =>
      ["DP_PAID", "PARTIAL_PAID", "FULL_PAID", "ONGOING"].includes(b.status)
    ).length;
    const pendingVerifications = MEMORY_ARTISTS.filter(
      (a) => a.status === "pending"
    ).length;
    const openDisputes = MEMORY_DISPUTES.filter((d) => d.status === "open").length;

    return {
      gmv,
      totalBookings,
      platformRevenue,
      activeJobs,
      pendingVerifications,
      openDisputes,
      recentBookings: MEMORY_BOOKINGS.slice(0, 5),
    };
  }

  /**
   * Admin: List pending artist stalls for KYC KTP verification
   */
  static async getPendingVerifications(): Promise<ArtistRecord[]> {
    try {
      const supabase = getSupabaseServerClient();
      const { data, error } = await supabase
        .from("artist_profiles")
        .select("*")
        .eq("status", "pending");
      if (!error && data && data.length > 0) {
        return data as ArtistRecord[];
      }
    } catch {}
    return MEMORY_ARTISTS.filter((a) => a.status === "pending");
  }

  /**
   * Admin: Approve or reject stall registration
   */
  static async updateArtistStatus(
    artistId: string,
    status: "verified" | "suspended"
  ) {
    try {
      const supabase = getSupabaseServerClient();
      await supabase
        .from("artist_profiles")
        .update({ status })
        .eq("id", artistId);
    } catch {}

    const artist = MEMORY_ARTISTS.find((a) => a.id === artistId);
    if (!artist) throw new Error("Artis tidak ditemukan");
    artist.status = status;
    return artist;
  }

  /**
   * Admin: List payouts and trigger disbursement
   */
  static async getPayouts(): Promise<PayoutRecord[]> {
    try {
      const supabase = getSupabaseServerClient();
      const { data, error } = await supabase.from("payouts").select("*");
      if (!error && data && data.length > 0) {
        return data as PayoutRecord[];
      }
    } catch {}
    return MEMORY_PAYOUTS;
  }

  static async triggerDisbursement(payoutId: string) {
    try {
      const supabase = getSupabaseServerClient();
      await supabase
        .from("payouts")
        .update({ status: "COMPLETED" })
        .eq("id", payoutId);
    } catch {}

    const payout = MEMORY_PAYOUTS.find((p) => p.id === payoutId);
    if (!payout) throw new Error("Payout record not found");
    payout.status = "COMPLETED";
    payout.disbursement_id = `DISB-XND-${Date.now()}`;
    return payout;
  }

  /**
   * Admin: List disputes & mediation
   */
  static async getDisputes(): Promise<DisputeRecord[]> {
    try {
      const supabase = getSupabaseServerClient();
      const { data, error } = await supabase.from("disputes").select("*");
      if (!error && data && data.length > 0) {
        return data as DisputeRecord[];
      }
    } catch {}
    return MEMORY_DISPUTES;
  }

  static async resolveDispute(
    disputeId: string,
    verdict: string,
    action: "refund_customer" | "release_group"
  ) {
    try {
      const supabase = getSupabaseServerClient();
      await supabase
        .from("disputes")
        .update({ status: "resolved", verdict })
        .eq("id", disputeId);
    } catch {}

    const dispute = MEMORY_DISPUTES.find((d) => d.id === disputeId);
    if (!dispute) throw new Error("Dispute record not found");

    dispute.status = "resolved";
    dispute.verdict = verdict;

    const newPayoutStatus = action === "refund_customer" ? "FAILED" : "HOLD";
    const payout = MEMORY_PAYOUTS.find((p) => p.booking_id === dispute.booking_id);
    if (payout) {
      payout.status = newPayoutStatus;
    }

    try {
      const supabase = getSupabaseServerClient();
      await supabase
        .from("payouts")
        .update({ status: newPayoutStatus })
        .eq("booking_id", dispute.booking_id);
    } catch {}

    return dispute;
  }
}

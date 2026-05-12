const kNorthProvinces = [
  'Hanoi', 'Hai Phong', 'Bac Ninh', 'Bac Giang', 'Ha Nam', 'Ha Giang',
  'Cao Bang', 'Lang Son', 'Lao Cai', 'Tuyen Quang', 'Yen Bai', 'Thai Nguyen',
  'Phu Tho', 'Vinh Phuc', 'Hai Duong', 'Hung Yen', 'Nam Dinh', 'Thai Binh',
  'Ninh Binh', 'Quang Ninh', 'Bac Kan', 'Hoa Binh', 'Dien Bien', 'Lai Chau',
  'Son La',
];

const kCentralProvinces = [
  'Thanh Hoa', 'Nghe An', 'Ha Tinh', 'Quang Binh', 'Quang Tri',
  'Thua Thien Hue', 'Da Nang', 'Quang Nam', 'Quang Ngai', 'Binh Dinh',
  'Phu Yen', 'Khanh Hoa', 'Ninh Thuan', 'Binh Thuan',
  'Kon Tum', 'Gia Lai', 'Dak Lak', 'Dak Nong', 'Lam Dong',
];

const kSouthProvinces = [
  'Ho Chi Minh City', 'Binh Duong', 'Dong Nai', 'Ba Ria Vung Tau',
  'Long An', 'Tien Giang', 'Ben Tre', 'Tra Vinh', 'Vinh Long', 'Dong Thap',
  'An Giang', 'Kien Giang', 'Can Tho', 'Hau Giang', 'Soc Trang', 'Bac Lieu',
  'Ca Mau', 'Binh Phuoc', 'Tay Ninh',
];

const kAllProvinces = [...kNorthProvinces, ...kCentralProvinces, ...kSouthProvinces];

String regionForProvince(String province) {
  if (kNorthProvinces.contains(province)) return 'North';
  if (kCentralProvinces.contains(province)) return 'Central';
  return 'South';
}

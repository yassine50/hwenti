import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  // Seed hidden test account
  const hashedPassword = await bcrypt.hash('JhM1Yq7o9$', 10);
  await prisma.user.upsert({
    where: { email: 'abacus-df78916d@example.com' },
    update: {},
    create: {
      email: 'abacus-df78916d@example.com',
      password: hashedPassword,
      name: 'Admin',
      role: 'visitor',
    },
  });

  // Seed all 24 Tunisian governorates with delegations
  const governorates = [
    {
      name: 'tunis', nameAr: 'تونس', nameFr: 'Tunis', lat: 36.8065, lng: 10.1815,
      delegations: [
        { name: 'medina', nameAr: 'المدينة', nameFr: 'Médina' },
        { name: 'bab_bhar', nameAr: 'باب البحر', nameFr: 'Bab El Bhar' },
        { name: 'bab_souika', nameAr: 'باب سويقة', nameFr: 'Bab Souika' },
        { name: 'halk_el_oued', nameAr: 'حلق الوادي', nameFr: 'Halk El Oued' },
        { name: 'el_kram', nameAr: 'الكرم', nameFr: 'El Kram' },
        { name: 'la_marsa', nameAr: 'المرسى', nameFr: 'La Marsa' },
        { name: 'sidi_bechir', nameAr: 'سيدي البشير', nameFr: 'Sidi El Béchir' },
        { name: 'jebel_ahmar', nameAr: 'الجبل الأحمر', nameFr: 'Djebel Jelloud' },
        { name: 'ettahrir', nameAr: 'التحرير', nameFr: 'Ettahrir' },
        { name: 'el_menzah', nameAr: 'المنزه', nameFr: 'El Menzah' },
        { name: 'hay_khadra', nameAr: 'حي الخضراء', nameFr: 'Cité El Khadra' },
        { name: 'ouardia', nameAr: 'الوردية', nameFr: 'El Ouardia' },
        { name: 'hrairia', nameAr: 'الحرائرية', nameFr: 'El Hrairia' },
        { name: 'sijoumi', nameAr: 'السيجومي', nameFr: 'Séjoumi' },
        { name: 'ezzouhour', nameAr: 'الزهور', nameFr: 'Ezzouhour' },
        { name: 'kabaria', nameAr: 'الكبارية', nameFr: 'El Kabaria' },
      ]
    },
    {
      name: 'ariana', nameAr: 'أريانة', nameFr: 'Ariana', lat: 36.8663, lng: 10.1647,
      delegations: [
        { name: 'ariana_ville', nameAr: 'أريانة المدينة', nameFr: 'Ariana Ville' },
        { name: 'soukra', nameAr: 'سكرة', nameFr: 'La Soukra' },
        { name: 'raoued', nameAr: 'رواد', nameFr: 'Raoued' },
        { name: 'kalaat_andalous', nameAr: 'قلعة الأندلس', nameFr: 'Kalâat El Andalous' },
        { name: 'sidi_thabet', nameAr: 'سيدي ثابت', nameFr: 'Sidi Thabet' },
        { name: 'hay_ettadhamen', nameAr: 'حي التضامن', nameFr: 'Ettadhamen' },
        { name: 'mnihla', nameAr: 'المنيهلة', nameFr: 'Mnihla' },
      ]
    },
    {
      name: 'ben_arous', nameAr: 'بن عروس', nameFr: 'Ben Arous', lat: 36.7471, lng: 10.2194,
      delegations: [
        { name: 'ben_arous_ville', nameAr: 'بن عروس', nameFr: 'Ben Arous' },
        { name: 'medina_jedida', nameAr: 'المدينة الجديدة', nameFr: 'Nouvelle Medina' },
        { name: 'mourouj', nameAr: 'المروج', nameFr: 'El Mourouj' },
        { name: 'hammam_lif', nameAr: 'حمام الأنف', nameFr: 'Hammam Lif' },
        { name: 'hammam_chott', nameAr: 'حمام الشط', nameFr: 'Hammam Chott' },
        { name: 'boumhel', nameAr: 'بومهل البساتين', nameFr: 'Boumhel El Bassatine' },
        { name: 'ezzahra', nameAr: 'الزهراء', nameFr: 'Ezzahra' },
        { name: 'rades', nameAr: 'رادس', nameFr: 'Radès' },
        { name: 'megrine', nameAr: 'مقرين', nameFr: 'Mégrine' },
        { name: 'mohamedia', nameAr: 'المحمدية', nameFr: 'Mohamedia' },
        { name: 'fouchana', nameAr: 'فوشانة', nameFr: 'Fouchana' },
        { name: 'mornag', nameAr: 'مرناق', nameFr: 'Mornag' },
      ]
    },
    {
      name: 'manouba', nameAr: 'منوبة', nameFr: 'Manouba', lat: 36.8101, lng: 10.0863,
      delegations: [
        { name: 'manouba_ville', nameAr: 'منوبة', nameFr: 'Manouba' },
        { name: 'oued_ellil', nameAr: 'وادي الليل', nameFr: 'Oued Ellil' },
        { name: 'tebourba', nameAr: 'طبربة', nameFr: 'Tebourba' },
        { name: 'el_battan', nameAr: 'البطان', nameFr: 'El Battan' },
        { name: 'jedaida', nameAr: 'الجديدة', nameFr: 'Jedaïda' },
        { name: 'borj_amri', nameAr: 'برج العامري', nameFr: 'Borj El Amri' },
        { name: 'douar_hicher', nameAr: 'دوار هيشر', nameFr: 'Douar Hicher' },
        { name: 'mornaguia', nameAr: 'المرناقية', nameFr: 'Mornaguia' },
      ]
    },
    {
      name: 'nabeul', nameAr: 'نابل', nameFr: 'Nabeul', lat: 36.4561, lng: 10.7376,
      delegations: [
        { name: 'nabeul_ville', nameAr: 'نابل', nameFr: 'Nabeul' },
        { name: 'dar_chaabane', nameAr: 'دار شعبان الفهري', nameFr: 'Dar Chaâbane El Fehri' },
        { name: 'beni_khiar', nameAr: 'بني خيار', nameFr: 'Béni Khiar' },
        { name: 'korba', nameAr: 'قربة', nameFr: 'Korba' },
        { name: 'menzel_temime', nameAr: 'منزل تميم', nameFr: 'Menzel Temime' },
        { name: 'el_mida', nameAr: 'الميدة', nameFr: 'El Mida' },
        { name: 'soliman', nameAr: 'سليمان', nameFr: 'Soliman' },
        { name: 'grombalia', nameAr: 'قرمبالية', nameFr: 'Grombalia' },
        { name: 'bou_argoub', nameAr: 'بوعرقوب', nameFr: 'Bou Argoub' },
        { name: 'hammamet', nameAr: 'الحمامات', nameFr: 'Hammamet' },
        { name: 'beni_khalled', nameAr: 'بني خلاد', nameFr: 'Béni Khalled' },
        { name: 'takelsa', nameAr: 'تاكلسة', nameFr: 'Takelsa' },
        { name: 'hammam_ghezaz', nameAr: 'حمام الأغزاز', nameFr: 'Hammam Ghezaz' },
        { name: 'kelibia', nameAr: 'قليبية', nameFr: 'Kélibia' },
        { name: 'haouaria', nameAr: 'هوارية', nameFr: 'El Haouaria' },
        { name: 'menzel_bouzelfa', nameAr: 'منزل بوزلفة', nameFr: 'Menzel Bouzelfa' },
      ]
    },
    {
      name: 'zaghouan', nameAr: 'زغوان', nameFr: 'Zaghouan', lat: 36.4029, lng: 10.1429,
      delegations: [
        { name: 'zaghouan_ville', nameAr: 'زغوان', nameFr: 'Zaghouan' },
        { name: 'zriba', nameAr: 'الزريبة', nameFr: 'Ez-Zriba' },
        { name: 'bir_mcherga', nameAr: 'بئر مشارقة', nameFr: 'Bir Mcherga' },
        { name: 'el_fahs', nameAr: 'الفحص', nameFr: 'El Fahs' },
        { name: 'ennadhour', nameAr: 'الناظور', nameFr: 'En-Nadhour' },
        { name: 'saouaf', nameAr: 'صواف', nameFr: 'Saouaf' },
      ]
    },
    {
      name: 'bizerte', nameAr: 'بنزرت', nameFr: 'Bizerte', lat: 37.2746, lng: 9.8739,
      delegations: [
        { name: 'bizerte_nord', nameAr: 'بنزرت الشمالية', nameFr: 'Bizerte Nord' },
        { name: 'bizerte_sud', nameAr: 'بنزرت الجنوبية', nameFr: 'Bizerte Sud' },
        { name: 'sejnane', nameAr: 'سجنان', nameFr: 'Sejnane' },
        { name: 'joumine', nameAr: 'جومين', nameFr: 'Joumine' },
        { name: 'mateur', nameAr: 'ماطر', nameFr: 'Mateur' },
        { name: 'ghezala', nameAr: 'غزالة', nameFr: 'Ghezala' },
        { name: 'menzel_bourguiba', nameAr: 'منزل بورقيبة', nameFr: 'Menzel Bourguiba' },
        { name: 'tinja', nameAr: 'تينجة', nameFr: 'Tinja' },
        { name: 'utique', nameAr: 'أوتيك', nameFr: 'Utique' },
        { name: 'menzel_jemil', nameAr: 'منزل جميل', nameFr: 'Menzel Jemil' },
        { name: 'el_alia', nameAr: 'العالية', nameFr: 'El Alia' },
        { name: 'ras_jebel', nameAr: 'رأس الجبل', nameFr: 'Ras Jebel' },
        { name: 'ghar_el_melh', nameAr: 'جرزونة', nameFr: 'Ghar El Melh' },
      ]
    },
    {
      name: 'beja', nameAr: 'باجة', nameFr: 'Béja', lat: 36.7256, lng: 9.1817,
      delegations: [
        { name: 'beja_nord', nameAr: 'باجة الشمالية', nameFr: 'Béja Nord' },
        { name: 'beja_sud', nameAr: 'باجة الجنوبية', nameFr: 'Béja Sud' },
        { name: 'nefza', nameAr: 'نفزة', nameFr: 'Nefza' },
        { name: 'teboursouk', nameAr: 'تبرسق', nameFr: 'Téboursouk' },
        { name: 'testour', nameAr: 'تستور', nameFr: 'Testour' },
        { name: 'goubellat', nameAr: 'قبلاط', nameFr: 'Goubellat' },
        { name: 'medjez_el_bab', nameAr: 'مجاز الباب', nameFr: 'Medjez El Bab' },
        { name: 'amdoun', nameAr: 'عمدون', nameFr: 'Amdoun' },
        { name: 'thibar', nameAr: 'الطيبار', nameFr: 'Thibar' },
      ]
    },
    {
      name: 'jendouba', nameAr: 'جندوبة', nameFr: 'Jendouba', lat: 36.5013, lng: 8.7801,
      delegations: [
        { name: 'jendouba_ville', nameAr: 'جندوبة', nameFr: 'Jendouba' },
        { name: 'jendouba_nord', nameAr: 'جندوبة الشمالية', nameFr: 'Jendouba Nord' },
        { name: 'bou_salem', nameAr: 'بوسالم', nameFr: 'Bou Salem' },
        { name: 'tabarka', nameAr: 'طبرقة', nameFr: 'Tabarka' },
        { name: 'ain_draham', nameAr: 'عين دراهم', nameFr: 'Aïn Draham' },
        { name: 'fernana', nameAr: 'فرنانة', nameFr: 'Fernana' },
        { name: 'ghardimaou', nameAr: 'غار الدماء', nameFr: 'Ghardimaou' },
        { name: 'balta_bou_aouane', nameAr: 'بلطة بوعوان', nameFr: 'Balta Bou Aouane' },
        { name: 'oued_mliz', nameAr: 'وادي مليز', nameFr: 'Oued Mliz' },
      ]
    },
    {
      name: 'le_kef', nameAr: 'الكاف', nameFr: 'Le Kef', lat: 36.1826, lng: 8.7149,
      delegations: [
        { name: 'kef_ouest', nameAr: 'الكاف الغربية', nameFr: 'Le Kef Ouest' },
        { name: 'kef_est', nameAr: 'الكاف الشرقية', nameFr: 'Le Kef Est' },
        { name: 'nebeur', nameAr: 'نبر', nameFr: 'Nebeur' },
        { name: 'sakiet_sidi_youssef', nameAr: 'ساقية سيدي يوسف', nameFr: 'Sakiet Sidi Youssef' },
        { name: 'tajerouine', nameAr: 'تاجروين', nameFr: 'Tajerouine' },
        { name: 'kalaat_khasba', nameAr: 'القلعة الخصبة', nameFr: 'Kalâat Khasba' },
        { name: 'dahmani', nameAr: 'الدهماني', nameFr: 'Dahmani' },
        { name: 'el_ksour', nameAr: 'القصور', nameFr: 'El Ksour' },
        { name: 'jerissa', nameAr: 'جريسة', nameFr: 'Jérissa' },
        { name: 'es_sers', nameAr: 'السرس', nameFr: 'Es-Sers' },
        { name: 'touiref', nameAr: 'الطويرف', nameFr: 'Touiref' },
      ]
    },
    {
      name: 'siliana', nameAr: 'سليانة', nameFr: 'Siliana', lat: 36.0887, lng: 9.3645,
      delegations: [
        { name: 'siliana_nord', nameAr: 'سليانة الشمالية', nameFr: 'Siliana Nord' },
        { name: 'siliana_sud', nameAr: 'سليانة الجنوبية', nameFr: 'Siliana Sud' },
        { name: 'bou_arada', nameAr: 'بوعرادة', nameFr: 'Bou Arada' },
        { name: 'gaafour', nameAr: 'قعفور', nameFr: 'Gaafour' },
        { name: 'maktar', nameAr: 'مكثر', nameFr: 'Maktar' },
        { name: 'rouhia', nameAr: 'الروحية', nameFr: 'Rouhia' },
        { name: 'kesra', nameAr: 'كسرى', nameFr: 'Kesra' },
        { name: 'bargou', nameAr: 'برقو', nameFr: 'Bargou' },
        { name: 'el_aroussa', nameAr: 'العروسة', nameFr: 'El Aroussa' },
      ]
    },
    {
      name: 'sousse', nameAr: 'سوسة', nameFr: 'Sousse', lat: 35.8254, lng: 10.6360,
      delegations: [
        { name: 'sousse_medina', nameAr: 'سوسة المدينة', nameFr: 'Sousse Médina' },
        { name: 'sousse_riadh', nameAr: 'سوسة الرياض', nameFr: 'Sousse Riadh' },
        { name: 'sousse_jawhara', nameAr: 'سوسة جوهرة', nameFr: 'Sousse Jawhara' },
        { name: 'sousse_sidi_abdelhamid', nameAr: 'سوسة سيدي عبد الحميد', nameFr: 'Sousse Sidi Abdelhamid' },
        { name: 'hammam_sousse', nameAr: 'حمام سوسة', nameFr: 'Hammam Sousse' },
        { name: 'akouda', nameAr: 'أكودة', nameFr: 'Akouda' },
        { name: 'kalaa_kebira', nameAr: 'القلعة الكبرى', nameFr: 'Kalâa Kebira' },
        { name: 'sidi_bou_ali', nameAr: 'سيدي بوعلي', nameFr: 'Sidi Bou Ali' },
        { name: 'hergla', nameAr: 'هرقلة', nameFr: 'Hergla' },
        { name: 'enfidha', nameAr: 'النفيضة', nameFr: 'Enfidha' },
        { name: 'bouficha', nameAr: 'بوفيشة', nameFr: 'Bouficha' },
        { name: 'kondar', nameAr: 'كندار', nameFr: 'Kondar' },
        { name: 'msaken', nameAr: 'مساكن', nameFr: "M'saken" },
        { name: 'kalaa_seghira', nameAr: 'القلعة الصغرى', nameFr: 'Kalâa Seghira' },
        { name: 'zaouia_ksiba_thrayet', nameAr: 'الزاوية-القصيبة-الثريات', nameFr: 'Zaouiet Ksiba Thrayet' },
      ]
    },
    {
      name: 'monastir', nameAr: 'المنستير', nameFr: 'Monastir', lat: 35.7643, lng: 10.8113,
      delegations: [
        { name: 'monastir_ville', nameAr: 'المنستير', nameFr: 'Monastir' },
        { name: 'ouerdanine', nameAr: 'الوردانين', nameFr: 'Ouerdanine' },
        { name: 'sahline', nameAr: 'الساحلين', nameFr: 'Sahline' },
        { name: 'zeramdine', nameAr: 'زرمدين', nameFr: 'Zeramdine' },
        { name: 'bembla', nameAr: 'بنبلة', nameFr: 'Bembla' },
        { name: 'jemmal', nameAr: 'جمال', nameFr: 'Jemmal' },
        { name: 'bekalta', nameAr: 'بقالطة', nameFr: 'Békalta' },
        { name: 'teboulba', nameAr: 'طبلبة', nameFr: 'Téboulba' },
        { name: 'ksar_hellal', nameAr: 'قصر هلال', nameFr: 'Ksar Hellal' },
        { name: 'moknine', nameAr: 'المكنين', nameFr: 'Moknine' },
        { name: 'sayada_lamta_bou_hajar', nameAr: 'صيادة-لمطة-بوحجر', nameFr: 'Sayada Lamta Bou Hajar' },
        { name: 'beni_hassen', nameAr: 'البرادعة', nameFr: 'Beni Hassen' },
        { name: 'touza', nameAr: 'طوزة', nameFr: 'Touza' },
      ]
    },
    {
      name: 'mahdia', nameAr: 'المهدية', nameFr: 'Mahdia', lat: 35.5047, lng: 11.0622,
      delegations: [
        { name: 'mahdia_ville', nameAr: 'المهدية', nameFr: 'Mahdia' },
        { name: 'bou_merdes', nameAr: 'بومرداس', nameFr: 'Bou Merdes' },
        { name: 'el_jem', nameAr: 'الجم', nameFr: 'El Jem' },
        { name: 'chebba', nameAr: 'الشابة', nameFr: 'Chebba' },
        { name: 'ksour_essef', nameAr: 'قصور الساف', nameFr: 'Ksour Essef' },
        { name: 'melloulech', nameAr: 'ملولش', nameFr: 'Melloulèche' },
        { name: 'souassi', nameAr: 'السواسي', nameFr: 'Souassi' },
        { name: 'hebira', nameAr: 'هبيرة', nameFr: 'Hébira' },
        { name: 'ouled_chamekh', nameAr: 'أولاد الشامخ', nameFr: 'Ouled Chamekh' },
        { name: 'chorbane', nameAr: 'شربان', nameFr: 'Chorbane' },
        { name: 'essouassi', nameAr: 'الحنشة', nameFr: 'El Hencha' },
      ]
    },
    {
      name: 'sfax', nameAr: 'صفاقس', nameFr: 'Sfax', lat: 34.7406, lng: 10.7603,
      delegations: [
        { name: 'sfax_medina', nameAr: 'صفاقس المدينة', nameFr: 'Sfax Médina' },
        { name: 'sfax_ouest', nameAr: 'صفاقس الغربية', nameFr: 'Sfax Ouest' },
        { name: 'sfax_sud', nameAr: 'صفاقس الجنوبية', nameFr: 'Sfax Sud' },
        { name: 'sakiet_ezzit', nameAr: 'ساقية الزيت', nameFr: 'Sakiet Ezzit' },
        { name: 'sakiet_eddaier', nameAr: 'ساقية الداير', nameFr: 'Sakiet Eddaïer' },
        { name: 'thyna', nameAr: 'طينة', nameFr: 'Thyna' },
        { name: 'agareb', nameAr: 'عقارب', nameFr: 'Agareb' },
        { name: 'jebeniana', nameAr: 'جبنيانة', nameFr: 'Jebéniana' },
        { name: 'el_amra', nameAr: 'العامرة', nameFr: 'El Amra' },
        { name: 'el_hencha', nameAr: 'الحنشة', nameFr: 'El Hencha' },
        { name: 'menzel_chaker', nameAr: 'منزل شاكر', nameFr: 'Menzel Chaker' },
        { name: 'ghraiba', nameAr: 'الغريبة', nameFr: 'Ghraiba' },
        { name: 'bir_ali_ben_khalifa', nameAr: 'بئر علي بن خليفة', nameFr: 'Bir Ali Ben Khélifa' },
        { name: 'skhira', nameAr: 'الصخيرة', nameFr: 'Skhira' },
        { name: 'mahares', nameAr: 'المحرس', nameFr: 'Mahares' },
        { name: 'kerkennah', nameAr: 'قرقنة', nameFr: 'Kerkennah' },
      ]
    },
    {
      name: 'kairouan', nameAr: 'القيروان', nameFr: 'Kairouan', lat: 35.6781, lng: 10.0963,
      delegations: [
        { name: 'kairouan_nord', nameAr: 'القيروان الشمالية', nameFr: 'Kairouan Nord' },
        { name: 'kairouan_sud', nameAr: 'القيروان الجنوبية', nameFr: 'Kairouan Sud' },
        { name: 'chebika', nameAr: 'الشبيكة', nameFr: 'Chebika' },
        { name: 'sbikha', nameAr: 'السبيخة', nameFr: 'Sbikha' },
        { name: 'oueslatia', nameAr: 'الوسلاتية', nameFr: 'Oueslatia' },
        { name: 'haffouz', nameAr: 'حفوز', nameFr: 'Haffouz' },
        { name: 'ala', nameAr: 'العلاء', nameFr: 'Aïn Jelloula' },
        { name: 'hajeb_el_ayoun', nameAr: 'حاجب العيون', nameFr: 'Hajeb El Ayoun' },
        { name: 'nasrallah', nameAr: 'نصر الله', nameFr: 'Nasrallah' },
        { name: 'echrarda', nameAr: 'الشراردة', nameFr: 'Echrarda' },
        { name: 'bou_hajla', nameAr: 'بوحجلة', nameFr: 'Bou Hajla' },
      ]
    },
    {
      name: 'kasserine', nameAr: 'القصرين', nameFr: 'Kasserine', lat: 35.1676, lng: 8.8365,
      delegations: [
        { name: 'kasserine_nord', nameAr: 'القصرين الشمالية', nameFr: 'Kasserine Nord' },
        { name: 'kasserine_sud', nameAr: 'القصرين الجنوبية', nameFr: 'Kasserine Sud' },
        { name: 'ezzouhour_kas', nameAr: 'الزهور', nameFr: 'Ezzouhour' },
        { name: 'hassi_ferid', nameAr: 'حاسي الفريد', nameFr: 'Hassi El Ferid' },
        { name: 'sbeitla', nameAr: 'سبيطلة', nameFr: 'Sbeïtla' },
        { name: 'sbiba', nameAr: 'سبيبة', nameFr: 'Sbiba' },
        { name: 'jedeliane', nameAr: 'جدليان', nameFr: 'Jédéliane' },
        { name: 'el_ayoun', nameAr: 'العيون', nameFr: 'El Ayoun' },
        { name: 'thala', nameAr: 'تالة', nameFr: 'Thala' },
        { name: 'hidra', nameAr: 'حيدرة', nameFr: 'Hidra' },
        { name: 'foussana', nameAr: 'فوسانة', nameFr: 'Foussana' },
        { name: 'majel_bel_abbes', nameAr: 'ماجل بلعباس', nameFr: 'Majel Bel Abbès' },
        { name: 'feriana', nameAr: 'فريانة', nameFr: 'Fériana' },
      ]
    },
    {
      name: 'sidi_bouzid', nameAr: 'سيدي بوزيد', nameFr: 'Sidi Bouzid', lat: 35.0382, lng: 9.4858,
      delegations: [
        { name: 'sidi_bouzid_ouest', nameAr: 'سيدي بوزيد الغربية', nameFr: 'Sidi Bouzid Ouest' },
        { name: 'sidi_bouzid_est', nameAr: 'سيدي بوزيد الشرقية', nameFr: 'Sidi Bouzid Est' },
        { name: 'jelma', nameAr: 'جلمة', nameFr: 'Jelma' },
        { name: 'sbela', nameAr: 'سبالة أولاد عسكر', nameFr: 'Cebalet Ouled Asker' },
        { name: 'bir_el_hfay', nameAr: 'بئر الحفي', nameFr: 'Bir El Hafey' },
        { name: 'sidi_ali_ben_aoun', nameAr: 'سيدي علي بن عون', nameFr: 'Sidi Ali Ben Aoun' },
        { name: 'menzel_bouzaiane', nameAr: 'منزل بوزيان', nameFr: 'Menzel Bouzaïane' },
        { name: 'meknassy', nameAr: 'المكناسي', nameFr: 'Meknassy' },
        { name: 'souk_jedid', nameAr: 'سوق الجديد', nameFr: 'Souk Jedid' },
        { name: 'mezzouna', nameAr: 'المزونة', nameFr: 'Mezzouna' },
        { name: 'regueb', nameAr: 'الرقاب', nameFr: 'Regueb' },
        { name: 'ouled_haffouz', nameAr: 'أولاد حفوز', nameFr: 'Ouled Haffouz' },
      ]
    },
    {
      name: 'gabes', nameAr: 'قابس', nameFr: 'Gabès', lat: 33.8815, lng: 10.0982,
      delegations: [
        { name: 'gabes_medina', nameAr: 'قابس المدينة', nameFr: 'Gabès Médina' },
        { name: 'gabes_ouest', nameAr: 'قابس الغربية', nameFr: 'Gabès Ouest' },
        { name: 'gabes_sud', nameAr: 'قابس الجنوبية', nameFr: 'Gabès Sud' },
        { name: 'ghannouch', nameAr: 'غنوش', nameFr: 'Ghannouch' },
        { name: 'metouia', nameAr: 'المطوية', nameFr: 'Métouia' },
        { name: 'menzel_habib', nameAr: 'منزل الحبيب', nameFr: 'Menzel El Habib' },
        { name: 'el_hamma', nameAr: 'الحامة', nameFr: 'El Hamma' },
        { name: 'matmata', nameAr: 'مطماطة', nameFr: 'Matmata' },
        { name: 'nouvelle_matmata', nameAr: 'مطماطة الجديدة', nameFr: 'Nouvelle Matmata' },
        { name: 'mareth', nameAr: 'مارث', nameFr: 'Mareth' },
        { name: 'dkhilet_toujane', nameAr: 'دخيلة توجان', nameFr: 'Dkhilet Toujane' },
      ]
    },
    {
      name: 'medenine', nameAr: 'مدنين', nameFr: 'Médenine', lat: 33.3540, lng: 10.5055,
      delegations: [
        { name: 'medenine_nord', nameAr: 'مدنين الشمالية', nameFr: 'Médenine Nord' },
        { name: 'medenine_sud', nameAr: 'مدنين الجنوبية', nameFr: 'Médenine Sud' },
        { name: 'ben_guerdane', nameAr: 'بن قردان', nameFr: 'Ben Guerdane' },
        { name: 'zarzis', nameAr: 'جرجيس', nameFr: 'Zarzis' },
        { name: 'djerba_houmt_souk', nameAr: 'جربة حومة السوق', nameFr: 'Djerba Houmt Souk' },
        { name: 'djerba_midoun', nameAr: 'جربة ميدون', nameFr: 'Djerba Midoun' },
        { name: 'djerba_ajim', nameAr: 'جربة أجيم', nameFr: 'Djerba Ajim' },
        { name: 'sidi_makhlouf', nameAr: 'سيدي مخلوف', nameFr: 'Sidi Makhlouf' },
      ]
    },
    {
      name: 'tataouine', nameAr: 'تطاوين', nameFr: 'Tataouine', lat: 32.9297, lng: 10.4518,
      delegations: [
        { name: 'tataouine_nord', nameAr: 'تطاوين الشمالية', nameFr: 'Tataouine Nord' },
        { name: 'tataouine_sud', nameAr: 'تطاوين الجنوبية', nameFr: 'Tataouine Sud' },
        { name: 'smmar', nameAr: 'الصمار', nameFr: 'Smâr' },
        { name: 'bir_lahmar', nameAr: 'بئر الأحمر', nameFr: 'Bir Lahmar' },
        { name: 'ghomrassen', nameAr: 'غمراسن', nameFr: 'Ghomrassen' },
        { name: 'dhehiba', nameAr: 'ذهيبة', nameFr: 'Dhehiba' },
        { name: 'remada', nameAr: 'رمادة', nameFr: 'Remada' },
      ]
    },
    {
      name: 'gafsa', nameAr: 'قفصة', nameFr: 'Gafsa', lat: 34.4250, lng: 8.7842,
      delegations: [
        { name: 'gafsa_nord', nameAr: 'قفصة الشمالية', nameFr: 'Gafsa Nord' },
        { name: 'gafsa_sud', nameAr: 'قفصة الجنوبية', nameFr: 'Gafsa Sud' },
        { name: 'oum_el_araies', nameAr: 'أم العرائس', nameFr: 'Oum El Araies' },
        { name: 'redeyef', nameAr: 'الرديف', nameFr: 'Redeyef' },
        { name: 'metlaoui', nameAr: 'المتلوي', nameFr: 'Métlaoui' },
        { name: 'mdhilla', nameAr: 'المضيلة', nameFr: 'Mdhilla' },
        { name: 'sened', nameAr: 'السند', nameFr: 'Sened' },
        { name: 'belkhir', nameAr: 'بلخير', nameFr: 'Belkhir' },
        { name: 'sidi_aich', nameAr: 'سيدي عيش', nameFr: 'Sidi Aïch' },
        { name: 'el_ksar', nameAr: 'القصر', nameFr: 'El Ksar' },
        { name: 'el_guettar', nameAr: 'القطار', nameFr: 'El Guetar' },
        { name: 'sidi_boubaker', nameAr: 'السنام', nameFr: 'Sidi Boubaker' },
        { name: 'zannouch', nameAr: 'زنوش', nameFr: 'Zannouch' },
      ]
    },
    {
      name: 'tozeur', nameAr: 'توزر', nameFr: 'Tozeur', lat: 33.9197, lng: 8.1335,
      delegations: [
        { name: 'tozeur_ville', nameAr: 'توزر', nameFr: 'Tozeur' },
        { name: 'degache', nameAr: 'دقاش', nameFr: 'Degache' },
        { name: 'tameghza', nameAr: 'تمغزة', nameFr: 'Tameghza' },
        { name: 'nefta', nameAr: 'نفطة', nameFr: 'Nefta' },
        { name: 'hezoua', nameAr: 'حزوة', nameFr: 'Hazoua' },
      ]
    },
    {
      name: 'kebili', nameAr: 'قبلي', nameFr: 'Kébili', lat: 33.7072, lng: 8.9710,
      delegations: [
        { name: 'kebili_nord', nameAr: 'قبلي الشمالية', nameFr: 'Kébili Nord' },
        { name: 'kebili_sud', nameAr: 'قبلي الجنوبية', nameFr: 'Kébili Sud' },
        { name: 'souk_lahad', nameAr: 'سوق الأحد', nameFr: 'Souk El Ahad' },
        { name: 'douz_nord', nameAr: 'دوز الشمالية', nameFr: 'Douz Nord' },
        { name: 'douz_sud', nameAr: 'دوز الجنوبية', nameFr: 'Douz Sud' },
        { name: 'faouar', nameAr: 'الفوار', nameFr: 'El Faouar' },
      ]
    },
  ];

  for (const gov of governorates) {
    const governorate = await prisma.governorate.upsert({
      where: { name: gov.name },
      update: { nameAr: gov.nameAr, nameFr: gov.nameFr, latitude: gov.lat, longitude: gov.lng },
      create: { name: gov.name, nameAr: gov.nameAr, nameFr: gov.nameFr, latitude: gov.lat, longitude: gov.lng },
    });

    for (const del of gov.delegations) {
      await prisma.delegation.upsert({
        where: { governorateId_name: { governorateId: governorate.id, name: del.name } },
        update: { nameAr: del.nameAr, nameFr: del.nameFr },
        create: {
          governorateId: governorate.id,
          name: del.name,
          nameAr: del.nameAr,
          nameFr: del.nameFr,
        },
      });
    }
  }

  const demoPass = await bcrypt.hash('password123', 10);
  const tunisGov = await prisma.governorate.findUnique({ where: { name: 'tunis' } });
  const marsaDel = tunisGov
    ? await prisma.delegation.findUnique({ where: { governorateId_name: { governorateId: tunisGov.id, name: 'la_marsa' } } })
    : null;
  const sousseGov = await prisma.governorate.findUnique({ where: { name: 'sousse' } });
  const sfaxGov = await prisma.governorate.findUnique({ where: { name: 'sfax' } });

  const merchantUser = await prisma.user.upsert({
    where: { email: 'merchant@hwenti.tn' },
    update: {},
    create: {
      email: 'merchant@hwenti.tn',
      password: demoPass,
      name: 'ياسين التونسي',
      role: 'merchant',
    },
  });

  const visitorUser = await prisma.user.upsert({
    where: { email: 'visitor@hwenti.tn' },
    update: {},
    create: {
      email: 'visitor@hwenti.tn',
      password: demoPass,
      name: 'أمين بن علي',
      role: 'visitor',
    },
  });

  const existingProducts = await prisma.product.count();
  if (existingProducts === 0 && tunisGov && marsaDel) {
    const logoFile = await prisma.file.create({
      data: {
        userId: merchantUser.id,
        fileName: 'shop-logo.jpg',
        cloud_storage_path: 'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=400&auto=format&fit=crop&q=80',
        isPublic: true,
        contentType: 'image/jpeg',
      },
    });

    const merchant = await prisma.merchant.upsert({
      where: { userId: merchantUser.id },
      update: {},
      create: {
        userId: merchantUser.id,
        shopName: 'متجر قرطاج للإلكترونيات',
        tradeType: 'electronics',
        governorateId: tunisGov.id,
        delegationId: marsaDel.id,
        phone: '+216 22 345 678',
        logoFileId: logoFile.id,
        setupComplete: true,
      },
    });

    const sampleProducts = [
      {
        name: 'سماعات لاسلكية احترافية Pro',
        price: 185,
        phone: '+216 22 345 678',
        description: 'سماعات بلوتوث عازلة للضجيج بجودة صوت عالية وبطارية تدوم 30 ساعة مع ضمان سنة كاملة.',
        imgUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80',
        views: 42,
      },
      {
        name: 'ساعة ذكية رياضية مقاومة للماء',
        price: 240,
        phone: '+216 22 345 678',
        description: 'شاشة AMOLED عالية الدقة، متابعة نبضات القلب والتمارين الرياضية، متوافقة مع أندرويد و iOS.',
        imgUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80',
        views: 78,
      },
      {
        name: 'حقيبة جلدية طبيعية صناعة تقليدية تونسية',
        price: 120,
        phone: '+216 55 987 654',
        description: 'حقيبة يد فاخرة من الجلد الطبيعي المنجز يدوياً في المدينة العتيقة بتونس.',
        imgUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&auto=format&fit=crop&q=80',
        views: 31,
      },
      {
        name: 'آلة قهوة إسبريسو إيطالية 15 بار',
        price: 390,
        phone: '+216 22 345 678',
        description: 'محضرة قهوة إسبريسو وكابتشينو بقوة 15 بار مع خافق حليب مدمج من الفولاذ المقاوم للصدأ.',
        imgUrl: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800&auto=format&fit=crop&q=80',
        views: 64,
      },
    ];

    const expiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    for (const sp of sampleProducts) {
      const f = await prisma.file.create({
        data: {
          userId: merchantUser.id,
          fileName: 'product.jpg',
          cloud_storage_path: sp.imgUrl,
          isPublic: true,
          contentType: 'image/jpeg',
        },
      });
      const prod = await prisma.product.create({
        data: {
          merchantId: merchant.id,
          name: sp.name,
          price: sp.price,
          phone: sp.phone,
          description: sp.description,
          expiryDate: expiry,
          viewCount: sp.views,
        },
      });
      await prisma.productImage.create({
        data: {
          productId: prod.id,
          fileId: f.id,
          isPrimary: true,
          sortOrder: 0,
        },
      });
    }

    await prisma.rating.upsert({
      where: { userId_merchantId: { userId: visitorUser.id, merchantId: merchant.id } },
      update: { score: 5 },
      create: { userId: visitorUser.id, merchantId: merchant.id, score: 5 },
    });

    for (let i = 0; i < 8; i++) {
      await prisma.visitorStat.create({
        data: { governorateId: tunisGov.id, delegationId: marsaDel.id, latitude: 36.878, longitude: 10.324 },
      });
    }
    if (sousseGov) {
      for (let i = 0; i < 5; i++) {
        await prisma.visitorStat.create({
          data: { governorateId: sousseGov.id, latitude: 35.825, longitude: 10.636 },
        });
      }
    }
    if (sfaxGov) {
      for (let i = 0; i < 4; i++) {
        await prisma.visitorStat.create({
          data: { governorateId: sfaxGov.id, latitude: 34.74, longitude: 10.76 },
        });
      }
    }
  }

  console.log('Seed completed: 24 governorates with delegations + demo accounts & products');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

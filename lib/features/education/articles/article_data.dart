import 'package:flutter/material.dart';
import 'article_model.dart';

/// Repository data artikel edukasi osteoporosis
class ArticleData {
  static const List<ArticleModel> articles = [
    // 1. Artikel Utama: Mengenal Osteoporosis (Alodokter)
    ArticleModel(
      id: 'mengenal-osteoporosis',
      source: 'Alodokter',
      sourceColor: Color(0xFF0A7AFF),
      sourceInitial: 'A',
      title: 'Mengenal Osteoporosis',
      appBarTitle: 'Osteoporosis',
      description:
          'Kenali penyebab, gejala, faktor risiko, dan cara mencegah osteoporosis.',
      url: 'https://www.alodokter.com/osteoporosis',
      thumbnailUrl:
          'https://images.alodokter.com/dk0z4ums3/image/upload/v1653983746/attached_image/osteoporosis.jpg',
      heroAssetPath: 'assets/images/osteoporosis_hero.jpg',
      bannerBottomText: 'APA ITU OSTEOPOROSIS? TULANG KEROPOS, MUDAH PATAH!',
      sourceActionLabel: 'Baca artikel lengkap di Alodokter',
      sections: [
        // Section 1
        ArticleSection(
          number: 1,
          title: 'Pengertian Osteoporosis',
          paragraphs: [
            'Osteoporosis adalah kondisi ketika kepadatan tulang berkurang sehingga tulang menjadi keropos dan mudah patah. Kondisi ini sering tidak menimbulkan gejala sehingga biasanya baru terdiagnosis ketika penderitanya mengalami jatuh atau cedera yang menyebabkan patah tulang.',
            'Osteoporosis dapat dialami oleh siapa saja, baik anak-anak maupun orang dewasa. Namun, risiko kondisi ini meningkat seiring bertambahnya usia dan lebih sering terjadi pada wanita yang telah memasuki masa menopause. Hal ini berkaitan dengan penurunan kadar hormon estrogen yang berperan penting dalam menjaga kepadatan dan kekuatan tulang.',
          ],
        ),

        // Section 2
        ArticleSection(
          number: 2,
          title: 'Penyebab Osteoporosis',
          paragraphs: [
            'Osteoporosis berkaitan dengan proses pembaruan jaringan tulang, yaitu penggantian sel tulang lama dengan sel tulang baru. Proses ini berperan penting dalam menjaga kepadatan dan kekuatan tulang.',
            'Pada usia muda, pembentukan tulang masih berlangsung dengan baik sehingga kepadatan tulang dapat terbentuk secara optimal. Namun, seiring bertambahnya usia, proses pembaruan tulang akan melambat. Osteoporosis dapat terjadi apabila kepadatan tulang tidak terbentuk secara optimal sejak usia muda atau tidak dapat dipertahankan dengan baik seiring waktu.',
          ],
        ),

        // Section 3
        ArticleSection(
          number: 3,
          title: 'Faktor Risiko Osteoporosis',
          paragraphs: [
            'Osteoporosis dapat dipengaruhi oleh berbagai faktor yang meningkatkan risiko berkurangnya kepadatan tulang. Faktor risiko ini terbagi menjadi faktor yang tidak dapat dikendalikan dan faktor yang dapat dicegah atau ditangani.',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Faktor Risiko yang Tidak Dapat Dimodifikasi',
              description:
                  'Berikut ini adalah faktor-faktor yang dapat meningkatkan risiko osteoporosis dan tidak dapat dicegah atau dikendalikan:',
              icon: Icons.person_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
              bulletPoints: [
                'Mengalami pertambahan usia',
                'Berjenis kelamin wanita, terutama setelah menopause',
                'Memiliki riwayat osteoporosis dalam keluarga',
              ],
            ),
            ArticleInfoCard(
              title: 'Faktor Risiko yang Dapat Dimodifikasi',
              description:
                  'Selain itu, terdapat faktor risiko osteoporosis yang dapat dicegah atau ditangani, antara lain:',
              icon: Icons.settings_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
              bulletPoints: [
                'Penurunan hormon estrogen pada wanita atau testosteron pada pria',
                'Gangguan hormonal (Cushing, hiperparatiroidisme, dll)',
                'Gangguan makan (anoreksia nervosa)',
                'Kekurangan vitamin D dan kalsium',
                'Gangguan pencernaan (malabsorpsi, Crohn)',
                'Obat-obatan tertentu jangka panjang (kortikosteroid)',
                'Gaya hidup kurang aktif / jarang olahraga',
                'Merokok',
                'Alkohol berlebihan',
                'Penyakit tertentu (cystic fibrosis, hemofilia, dll)',
              ],
            ),
          ],
        ),

        // Section 4
        ArticleSection(
          number: 4,
          title: 'Gejala Osteoporosis',
          paragraphs: [
            'Sering tidak menimbulkan gejala pada tahap awal. Biasanya baru diketahui saat terjadi patah tulang. Ketika patah tulang, dapat muncul nyeri, bengkak, memar, dan keterbatasan gerak. Gejala lain yang bisa muncul:',
          ],
          infoCards: [
            ArticleInfoCard(
              isAlert: true,
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
              bulletPoints: [
                'Postur tubuh membungkuk',
                'Penurunan tinggi badan',
                'Nyeri punggung akibat patah tulang belakang',
              ],
            ),
          ],
        ),

        // Section 5
        ArticleSection(
          number: 5,
          title: 'Kapan Harus ke Dokter',
          doctorConsultation: ArticleDoctorConsultation(
            text:
                'Segera periksakan diri jika mengalami keluhan di atas. Jika memiliki faktor risiko (usia lanjut, menopause, gangguan hormonal), lakukan pemeriksaan rutin. Bila keluhan ringan mengarah pada osteoporosis, jangan tunda berkonsultasi ke dokter melalui Chat Bersama Dokter atau booking dokter di aplikasi ALODOKTER.',
            highlightedSource: 'ALODOKTER',
            consultationUrl: 'https://www.alodokter.com/tanya-dokter',
          ),
        ),

        // Section 6
        ArticleSection(
          number: 6,
          title: 'Diagnosis Osteoporosis',
          diagnosisBox: ArticleDiagnosisBox(
            introText:
                'Dokter akan melakukan tanya jawab, riwayat kesehatan, obat-obatan, dan pemeriksaan fisik. Pemeriksaan penunjang meliputi:',
            procedures: [
              DiagnosisItem(
                name: 'Rontgen / CT scan / MRI',
                description: '(melihat tulang patah)',
              ),
              DiagnosisItem(
                name: 'Tes darah',
                description:
                    '(darah, elektrolit, hormon tiroid, paratiroid, estrogen, testosteron)',
              ),
              DiagnosisItem(
                name: 'Tes BMD',
                description: '(DXA atau QCT) (melihat kepadatan tulang)',
              ),
            ],
            tScores: [
              TScoreItem(scoreRange: '> -1', status: 'Normal'),
              TScoreItem(scoreRange: '-1 s/d -2.5', status: 'Osteopenia'),
              TScoreItem(scoreRange: '< -2.5', status: 'Osteoporosis'),
            ],
          ),
        ),

        // Section 7
        ArticleSection(
          number: 7,
          title: 'Pengobatan Osteoporosis',
          paragraphs: [
            'Pengobatan osteoporosis bertujuan mencegah terjadinya patah tulang, mengurangi rasa nyeri, dan mempertahankan kepadatan massa tulang penderita. Dokter akan menyesuaikan pengobatan berdasarkan usia, jenis kelamin, serta tingkat risiko fraktur:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Pilihan Terapi Medis & Suplementasi',
              icon: Icons.medication_rounded,
              iconColor: Color(0xFF0A7AFF),
              iconBgColor: Color(0xFFEFF6FF),
              bulletPoints: [
                'Bifosfonat (Alendronate, Risedronate, Zoledronic Acid): Memperlambat pengikisan sel tulang lama',
                'Terapi Hormon & SERM (Raloxifene): Mempertahankan kepadatan tulang pada wanita pascamenopause',
                'Antibodi Monoklonal (Denosumab): Diberikan melalui suntikan tiap 6 bulan untuk menghambat resorpsi tulang',
                'Agen Anabolik (Teriparatide): Merangsang pembentukan jaringan tulang baru pada kasus osteoporosis berat',
                'Suplemen Kalsium (1.000–1.200 mg/hari) & Vitamin D3: Nutrisi fundamental pembentuk matriks tulang',
              ],
            ),
          ],
        ),

        // Section 8
        ArticleSection(
          number: 8,
          title: 'Komplikasi Osteoporosis',
          paragraphs: [
            'Jika tidak terdeteksi dan tidak ditangani dengan tepat, osteoporosis dapat memicu komplikasi serius yang mengancam keselamatan dan kemandirian penderita:',
          ],
          infoCards: [
            ArticleInfoCard(
              isAlert: true,
              title: 'Risiko Komplikasi Berat',
              icon: Icons.error_outline_rounded,
              iconColor: Color(0xFFDC2626),
              iconBgColor: Color(0xFFFEE2E2),
              bulletPoints: [
                'Patah tulang pinggul (hip fracture) yang memerlukan tindakan operasi darurat dan berisiko tirah baring lama',
                'Patah kompresi tulang belakang (vertebral compression) yang menyebabkan nyeri punggung kronis dan bungkuk permanen (kifosis)',
                'Patah tulang pergelangan tangan akibat refleks menahan saat terpeleset atau terjatuh',
                'Penurunan kemandirian fisik secara drastis serta peningkatan risiko komplikasi tirah baring',
              ],
            ),
          ],
        ),

        // Section 9
        ArticleSection(
          number: 9,
          title: 'Pencegahan Osteoporosis',
          paragraphs: [
            'Kesehatan tulang harus dijaga sedini mungkin sebelum massa tulang mengalami penurunan alami. Langkah pencegahan utama yang dianjurkan para dokter meliputi:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Langkah Pencegahan Utama',
              icon: Icons.health_and_safety_rounded,
              iconColor: Color(0xFF16A34A),
              iconBgColor: Color(0xFFDCFCE7),
              bulletPoints: [
                'Aktivitas fisik menahan beban (jalan cepat, jogging, senam osteoporosis, latihan kekuatan otot) minimal 30 menit sehari',
                'Konsumsi makanan tinggi kalsium (susu, yoghurt, keju, ikan sarden, teri, bayam, brokoli, tahu, dan tempe)',
                'Cukupi kebutuhan vitamin D dari paparan sinar matahari pagi (10-15 menit) dan kuning telur atau salmon',
                'Berhenti merokok dan hindari konsumsi alkohol berlebihan karena dapat menghambat penyerapan kalsium',
                'Modifikasi rumah aman: sediakan pegangan di kamar mandi, hindari karpet licin, dan pastikan pencahayaan terang untuk mencegah risiko jatuh',
              ],
            ),
          ],
        ),
      ],
    ),

    // 2. Artikel: Jenis Osteoporosis dan Cara Mencegahnya (Kementerian Kesehatan RI)
    ArticleModel(
      id: 'jenis-osteoporosis-dan-cara-mencegahnya',
      source: 'Kementerian Kesehatan RI',
      sourceColor: Color(0xFF00897B),
      sourceInitial: 'K',
      title: 'Jenis Osteoporosis dan Cara Mencegahnya',
      appBarTitle: 'Jenis Osteoporosis & Pencegahan',
      description:
          'Kenali jenis-jenis osteoporosis dan langkah pencegahannya untuk menjaga kesehatan tulang.',
      url:
          'https://keslan.kemkes.go.id/view_artikel/3179/apa-saja-jenis-osteoporosis-dan-cara-mencegahnya',
      thumbnailUrl:
          'https://keslan.kemkes.go.id/assets/images/osteoporosis_thumbnail.jpg',
      heroAssetPath: 'assets/images/kemenkes_hero.jpg',
      bannerBottomText: 'KLASIFIKASI & PENCEGAHAN OSTEOPOROSIS',
      sourceActionLabel: 'Baca Artikel Asli',
      sections: [
        // Section 1
        ArticleSection(
          number: 1,
          title: 'Pengertian Osteoporosis',
          paragraphs: [
            'Osteoporosis berasal dari kata osteo dan porous, osteo artinya tulang dan porous berarti berlubang-lubang atau keropos. Jadi osteoporosis adalah tulang yang keropos, yaitu penyakit yang mempunyai sifat khas berupa massa tulangnya rendah atau berkurang, disertai gangguan mikro arsitektur tulang dan penurunan kualitas jaringan tulang, yang dapat menimblkan kerapuhan tulang. Tulang yang rapuh dan keropos ini mudah patah atau fraktur (fracture).',
            'Osteoporosis merupakan penyakit tulang dengan gejala menurunnya kepadatan tulang secara keseluruhan karena tubuh tidak mampu mengatur kandungan mineral yang ada dalam tulang. Osteoporosis disertai dengan rusaknya arsitektur tulang sehingga mengakibatkan penurunan kekuatan tulang dan pengeroposan tulang sehingga menyebabkan mudah terjadi patah tulang.',
            'Osteoporosis adalah penyakit silent disease karena osteoporosis tidak menunjukkan gejala-gejala yang spesifik dan khas. Gejala osteoporosis adalah nyeri pada tulang, nyeri otot, nyeri sering terjadi pada punggung, adanya tulang yang patah, kemudian semakin membungkuknya tulang punggung, dan penurunan tinggi badan, dan terdapat nyeri pada punggung.',
            'Osteoporosis dapat menimbulkan beban bukan hanya bagi penderita tetapi juga bagi keluarga. Oleh karena itu tindakan preventif perlu menjadi perhatian bagi kita. Karena begitu tinggi kematian akibat patah tulang, maka upaya preventif merupakan prioritas utama dalam pelayanan kesehatan di Indonesia. Tindakan preventif dapat dimulai dengan melakukan promosi kesehatan, memberikan edukasi kepada masyarakat Indonesia bahwa osteoporosis dapat kita cegah dari masa anak-anak dengan mengkonsumsi makanan yang mengandung kalsium yang cukup dan melakukan pola hidup sehat dan aktif juga merupakan hal utama untuk menghindari kejadian osteoporosis.',
          ],
        ),

        // Section 2
        ArticleSection(
          number: 2,
          title: 'Karakteristik Osteoporosis',
          paragraphs: [
            'Karakteristik osteoporosis adalah ditandai dengan adanya penurunan kekuatan tulang (bone strength). Kekuatan tulang ini adalah hasil integrasi antara volume mineralisasi, arsitektur tulang, bone turn over, dan akumulasi kerusakan tulang. Osteoporosis identik dengan kehilangan massa tulang, yaitu kelainan tulang yang merujuk pada kelainan kekuatan tulang. Apabila kekuatan tulang ini menurun maka hal ini dapat menjadi faktor predisposisi terjadinya fraktur.',
          ],
        ),

        // Section 3
        ArticleSection(
          number: 3,
          title: 'Jenis Osteoporosis',
          paragraphs: [
            'Banyak yang menganggap bahwa osteoporosis hanya milik lanjut usia atau wanita sesudah menopause, yaitu osteoporosis primer ini. Namun, sebenarnya masih bisa ditemukan pada orang muda akibat berbagai penyebab, yaitu osteoporosis sekunder.',
            '### 1. Osteoporosis Primer',
            'Menopause umumnya terjadi pada usia 50-an, hormon estrogen wanita akan turun 2-3 tahun sebelum menopause timbul, dan terus berangsung sampai3-4 tahun setelah menopause. Masa tulang akan berkurang 1-3 persen dalam 5-7 tahun pertama setelah menopause. Dan ketika berusia 70 tahun, proses pengeroposan akan berkurang, tetapi tidak akan berhenti, sampai akhirnya total seseorang wanita akan kehilangan 35-50 persen dari tulangnya pada usia lanjut. Banyak orang yang beranggapan bahwa osteoporosis hanya milik orang tua atau wanita sesudah menopause, yaitu osteoporosis primer ini.',
            '### 2. Osteoporosis Sekunder',
            'Osteoporosis sekunder disebabkan oleh penyakit atau kelainan tertentu atau bisa pula akibat tindakan pembedahan atau pemberian obat yang mempercepat pengeroposan tulang. Osteoporosis sekunder bisa ditemukan pada hamper dua pertiga pria, dan lebih dari separuh wanita sebelum menopause, dengan penyebab yang bermacam macam, yang mengakibatkan penurunan densitas tulang dan peningkatan kemungkinan patah tulang. Keadaan ini perlu diwaspadai dan secepatnya dilakukan upaya pencegahan dan pengobatan yang lebih baik.',
            'Penanganan osteoporosis primer dan sekunder tidak banyak berbeda. Karena penyebabnya berlainan, maka perlu tindakan khusus untuk mengatasi sebab-sebab terjadinya osteoporosis.',
          ],
        ),

        // Section 4
        ArticleSection(
          number: 4,
          title: 'Gejala Osteoporosis',
          paragraphs: [
            'Pada awalnya osteoporosis tidak menimbulkan gejala, bahkan sampai puluhan tahun tanpa keluhan. Jika kepadatan tulang sangat berkurang sehingga tulang menjadi kolaps atau hancur, akan timbul nyeri dan perubahan bentuk tulang. Jadi, seseorang dengan osteoporosis biasanya akan memberikan keluhan atau gejala sebagai berikut:',
            '1.  Tinggi badan berkurang.',
            '2.  Bungkuk atau bentuk tubuh berubah.',
            '3.  Patah tulang.',
            '4.  Nyeri bila ada patah tulang.',
            'Kolaps tulang belakang menyebabkan nyeri punggung yang menahun. Tulang belakang yang rapuh bisa mengalami kolaps secara spontan hanya karena cedera yang ringan. Biasanya nyeri timbul secra tiba-tiba dan dirasakan di daerah tertentu punggung, yang akan bertambah nyeri jika penderita berdiri atau berjalan.',
          ],
        ),

        // Section 5
        ArticleSection(
          number: 5,
          title: 'Cara Mencegah Osteoporosis',
          paragraphs: [
            'Untuk mencegah terjadinya osteoporosis dapat dilakukan dengan mengkonsumsi kalsium yang cukup, mendapatkan asupan Vitamin D dari sinar matahari, dan hidup aktif dengan melakukan aktifitas fisik dengan prinsip pembebanan terhadap tulang, yang bisa dilakukan dengan berjalan kaki. Selain itu, kita harus menghindari merokok, minum alkohol dan melakukan pemeriksaan kepadatan tulang. Mencegah osteoporosis harus dilakukan sedini mungkin untuk mencapai kepadatan tulang yang maksimal.',
          ],
        ),
      ],
    ),

    // 3. Artikel: Pencegahan Osteoporosis Sejak Usia Muda (AFMC)
    ArticleModel(
      id: 'pencegahan-osteoporosis-afmc',
      source: 'AFMC',
      sourceColor: Color(0xFF0055B7),
      sourceInitial: 'A',
      title: 'Pencegahan Osteoporosis Sejak Usia Muda',
      appBarTitle: 'Pencegahan Sejak Dini',
      description:
          'Pelajari langkah pencegahan osteoporosis sejak dini untuk menjaga kesehatan dan kekuatan tulang.',
      url:
          'https://www-afmc-org.translate.goog/blog/start-young-to-prevent-osteoporosis?_x_tr_sl=en&_x_tr_tl=id&_x_tr_hl=id&_x_tr_pto=tc',
      thumbnailUrl: 'https://www.afmc.org/images/news/OsteoporosisCOVER.png',
      heroAssetPath: 'assets/images/afmc_hero.jpg',
      bannerBottomText: 'PUNCAK MASSA TULANG & PENCEGAHAN SEJAK DINI',
      sourceActionLabel: 'Baca Artikel Asli',
      sections: [
        ArticleSection(
          number: 1,
          title: 'Mengapa Pencegahan Harus Dimulai Sejak Usia Muda?',
          paragraphs: [
            'Menurut National Osteoporosis Foundation (NOF), sekitar 54 juta orang menderita osteoporosis atau massa tulang rendah (osteopenia). Osteoporosis adalah penyakit yang melemahkan tulang secara bertahap hingga rapuh dan mudah patah. Kondisi ini menjadi penyebab umum hilangnya kemandirian hidup pada lansia, terutama wanita pascamenopause.',
            'Upaya pencegahan osteoporosis tidak bisa ditunda sampai usia senja. Membangun puncak massa tulang (Peak Bone Mass / PBM) optimal di usia 17 hingga 25 tahun adalah fondasi paling krusial untuk mencegah pengeroposan tulang di kemudian hari.',
          ],
        ),
        ArticleSection(
          number: 2,
          title: 'Puncak Massa Tulang (Peak Bone Mass / PBM)',
          paragraphs: [
            'Kebanyakan pria dan wanita mencapai puncak massa tulang antara rentang usia 17 hingga 25 tahun. Semakin tinggi cadangan kepadatan tulang yang berhasil Anda bentuk di masa muda, semakin rendah risiko mengalami osteoporosis ketika massa tulang mulai menyusut alami seiring pertambahan usia.',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Fakta Puncak Massa Tulang (AFMC)',
              icon: Icons.insights_rounded,
              iconColor: Color(0xFF0055B7),
              iconBgColor: Color(0xFFE6F0FA),
              bulletPoints: [
                'Puncak massa tulang (PBM) tercapai optimal pada rentang usia 17–25 tahun.',
                'Pria umumnya memiliki cadangan PBM lebih tinggi dan laju penyusutan tulang lebih lambat dibandingkan wanita.',
                'CDC mencatat osteoporosis dialami oleh sekitar 20% (1 dari 5) wanita dan 5% (1 dari 20) pria usia 50 tahun ke atas.',
                'Wanita bertubuh langsing dan bertulang kecil (terutama ras Asia dan Kaukasia) memiliki risiko pengeroposan tertinggi.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 3,
          title: 'Tulang Rapuh, Risiko Fraktur & Pemulihan Lambat',
          paragraphs: [
            'Osteoporosis sering dijuluki "silent disease" karena tidak menimbulkan gejala awal sampai terjadi patah tulang pertama. Batuk keras atau benturan ringan saja sudah cukup memicu patah tulang pada penderita osteoporosis berat.',
          ],
          infoCards: [
            ArticleInfoCard(
              isAlert: true,
              title: 'Area Fraktur Paling Rentan & Komplikasi',
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
              bulletPoints: [
                'Patah tulang pinggul (hip fracture): Sangat serius, menyebabkan pasien kehilangan kemandirian, dan berisiko komplikasi fatal pascaoperasi.',
                'Patah tulang belakang (spine): Menimbulkan nyeri kronis berkepanjangan dan perubahan postur tubuh membungkuk.',
                'Patah pergelangan tangan & lengan bawah: Sering dialami saat refleks menahan tubuh saat terjatuh.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 4,
          title: 'Langkah Nyata Pencegahan Osteoporosis dari AFMC',
          paragraphs: [
            'Pencegahan osteoporosis dimulai dari pilihan gaya hidup sehat sehari-hari yang dibiasakan sejak dini:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: '5 Rekomendasi Pencegahan Utama',
              icon: Icons.health_and_safety_rounded,
              iconColor: Color(0xFF0055B7),
              iconBgColor: Color(0xFFE6F0FA),
              bulletPoints: [
                'Olahraga menahan beban (Weight-bearing exercises): Jalan kaki, jogging, lompat tali, hiking, atau tenis minimal 30 menit sehari untuk merangsang pertumbuhan sel tulang baru.',
                'Nutrisi kaya kalsium alami: Utamakan asupan kalsium dari makanan utuh bergizi seperti susu, sayuran hijau, dan ikan.',
                'Cukupi kebutuhan vitamin D: Membantu penyerapan kalsium optimal ke dalam kerangka tubuh.',
                'Berhenti merokok: Merokok menghambat kemampuan tubuh menyerap dan membangun kalsium.',
                'Batasi konsumsi alkohol: Maksimal 1 gelas/hari untuk wanita dan 2 gelas/hari untuk pria.',
                'Amankan rumah dari risiko jatuh (Fall-proofing): Gunakan alas anti-licin dan pastikan pencahayaan cukup untuk mencegah lansia terpeleset.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 5,
          title: 'Kapan Harus Menjalani Skrining Osteoporosis?',
          paragraphs: [
            'U.S. Preventive Services Task Force merekomendasikan pemeriksaan kepadatan tulang untuk wanita berusia di atas 65 tahun, atau wanita pascamenopause di bawah 65 tahun yang memiliki faktor risiko tinggi.',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Metode Evaluasi & Pesan Penting AFMC',
              icon: Icons.checklist_rounded,
              iconColor: Color(0xFFF38A00),
              iconBgColor: Color(0xFFFEF4E6),
              bulletPoints: [
                'Dual-Energy X-Ray Absorptiometry (DXA/DEXA scan): Prosedur cepat dan tanpa rasa sakit untuk mengukur densitas mineral tulang.',
                'Kalkulator FRAX (Fracture Risk Assessment Tool): Alat penilaian mandiri untuk mengestimasi risiko patah tulang dalam 10 tahun ke depan.',
                'Pesan Utama AFMC: Jangan menunggu hingga mengalami patah tulang baru mulai memperkuat tulang Anda!',
              ],
            ),
          ],
        ),
      ],
    ),

    // 4. Artikel: Mitos dan Fakta Osteoporosis (Holistic Bodyworks)
    ArticleModel(
      id: 'mitos-dan-fakta-osteoporosis',
      source: 'Holistic Bodyworks',
      sourceColor: Color(0xFF018AAC),
      sourceInitial: 'H',
      title: 'Mitos dan Fakta Osteoporosis',
      appBarTitle: 'Mitos & Fakta',
      description:
          'Kupas tuntas 6 mitos keliru seputar osteoporosis dan fakta medis penting dari Holistic Bodyworks.',
      url:
          'https://www-holisticbodyworks-com-au.translate.goog/osteoporosis-myths-and-facts/?_x_tr_sl=en&_x_tr_tl=id&_x_tr_hl=id&_x_tr_pto=tc',
      thumbnailUrl:
          'https://www.holisticbodyworks.com.au/wp-content/uploads/2020/11/Osteoporosis.jpg',
      heroAssetPath: 'assets/images/mitos_fakta_hero.jpg',
      bannerBottomText: 'MITOS & FAKTA MEDIS OSTEOPOROSIS',
      sourceActionLabel: 'Baca artikel lengkap di Holistic Bodyworks',
      sections: [
        ArticleSection(
          number: 1,
          title: 'Apa Itu Osteoporosis?',
          paragraphs: [
            'Osteoporosis adalah kondisi yang memengaruhi kepadatan tulang kerangka tubuh sehingga menyebabkannya menjadi rapuh, lemah, dan rentan patah. Kondisi ini terjadi ketika tulang kehilangan protein dan mineral dalam jumlah tinggi, terutama kalsium, sehingga struktur mikro internal tulang menipis.',
            'Meskipun sebagian besar dialami oleh lansia, osteoporosis berkembang secara bertahap selama bertahun-tahun. Keputusan pola hidup sejak usia muda memegang peranan krusial terhadap kekuatan dan ketahanan tulang di masa tua.',
          ],
        ),
        ArticleSection(
          number: 2,
          title: 'Mitos 1 & 2: Jenis Kelamin dan Ras',
          paragraphs: [
            'Banyak anggapan keliru di masyarakat mengenai siapa saja yang dapat terkena pengeroposan tulang:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Mitos 1: Hanya Menyerang Wanita',
              description:
                  'Fakta: Wanita memang lebih rentan akibat penurunan hormon estrogen saat menopause. Namun pria juga berisiko tinggi — data menunjukkan seperlima (20%) pria berusia di atas 50 tahun akan mengalami patah tulang osteoporotik dalam hidup mereka!',
              icon: Icons.people_outline_rounded,
              iconColor: Color(0xFF018AAC),
              iconBgColor: Color(0xFFE0F4F8),
            ),
            ArticleInfoCard(
              title: 'Mitos 2: Hanya Memengaruhi Orang Kaukasia',
              description:
                  'Fakta: Osteoporosis dapat menyerang siapa saja dari berbagai ras dan etnis. Meskipun angka kejadian berbeda antar populasi, kesehatan tulang harus diprioritaskan oleh semua orang tanpa terkecuali.',
              icon: Icons.public_rounded,
              iconColor: Color(0xFF018AAC),
              iconBgColor: Color(0xFFE0F4F8),
            ),
          ],
        ),
        ArticleSection(
          number: 3,
          title: 'Mitos 3 & 4: Dampak Tubuh & Risiko Fraktur',
          paragraphs: [
            'Dampak osteoporosis tidak berhenti pada kerapuhan fisik tulang semata, melainkan dapat memicu komplikasi fatal yang lebih luas:',
          ],
          infoCards: [
            ArticleInfoCard(
              isAlert: true,
              title: 'Mitos 3: Hanya Berdampak Pada Tulang',
              description:
                  'Fakta: Patah tulang panggul akibat osteoporosis dapat berakibat fatal karena komplikasi pascaoperasi, tirah baring/imobilitas berkepanjangan, gangguan fungsi paru dan jantung, serta tingginya risiko infeksi.',
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFDC2626),
              iconBgColor: Color(0xFFFEE2E2),
            ),
            ArticleInfoCard(
              isAlert: true,
              title: 'Mitos 4: Tulang Hanya Patah Jika Terjatuh',
              description:
                  'Fakta: Pada penderita osteoporosis berat, gerakan sederhana sehari-hari seperti bersin keras, membungkuk mengambil barang di lantai, atau melangkah turun dari trotoar sudah dapat memicu patah tulang.',
              icon: Icons.personal_injury_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
            ),
          ],
        ),
        ArticleSection(
          number: 4,
          title: 'Mitos 5 & 6: Rasa Sakit & Waktu Pencegahan',
          paragraphs: [
            'Memahami rasa sakit dan waktu yang tepat untuk melakukan pencegahan:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Mitos 5: Osteoporosis Tidak Menimbulkan Nyeri',
              description:
                  'Fakta: Pada fase awal penyakit memang sering kali tanpa keluhan. Namun seiring waktu, fraktur kompresi berulang dan hilangnya massa otot (sarkopenia) memicu nyeri punggung kronis persisten yang mengganggu postur tubuh.',
              icon: Icons.healing_rounded,
              iconColor: Color(0xFF018AAC),
              iconBgColor: Color(0xFFE0F4F8),
            ),
            ArticleInfoCard(
              title: 'Mitos 6: Baru Perlu Khawatir Jika Sudah Terkena',
              description:
                  'Fakta: Puncak kepadatan tulang tercapai pada usia 18 tahun (wanita) dan 20 tahun (pria). Semakin tinggi massa tulang yang dibangun saat muda melalui olahraga dan nutrisi, semakin terlindungi tulang Anda di usia lanjut.',
              icon: Icons.lightbulb_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
            ),
          ],
        ),
        ArticleSection(
          number: 5,
          title: 'Bertindak Lebih Dini Bersama Holistic Bodyworks',
          paragraphs: [
            'Kunci utama pencegahan osteoporosis adalah bertindak sedini mungkin dengan membiasakan anak-anak dan remaja aktif bergerak, memenuhi nutrisi esensial tulang, serta melakukan evaluasi muskuloskeletal berkala.',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Langkah Nyata Melindungi Tulang',
              icon: Icons.health_and_safety_rounded,
              iconColor: Color(0xFF018AAC),
              iconBgColor: Color(0xFFE0F4F8),
              bulletPoints: [
                'Rutin melakukan aktivitas fisik yang menahan beban tubuh (weight-bearing exercise)',
                'Konsumsi makanan kaya kalsium dan cukupi kebutuhan vitamin D serta mineral harian',
                'Jaga kekuatan massa otot untuk mendukung stabilitas dan postur kerangka tubuh',
                'Konsultasikan keluhan postur atau nyeri tulang belakang ke praktisi osteopati & fisioterapi klinis',
              ],
            ),
          ],
        ),
      ],
    ),

    // 5. Artikel: Skrining & Deteksi Osteoporosis (RS Pondok Indah)
    ArticleModel(
      id: 'skrining-dan-deteksi-osteoporosis-rspi',
      source: 'RS Pondok Indah',
      sourceColor: Color(0xFF358888),
      sourceInitial: 'R',
      title: 'Skrining & Deteksi Osteoporosis',
      appBarTitle: 'Skrining & Deteksi',
      description:
          'Pelajari faktor risiko, skrining dini, dan pemeriksaan kepadatan tulang untuk mendeteksi osteoporosis.',
      url:
          'https://www.rspondokindah.co.id/id/news/deteksi-dan-cegah-osteoporosis',
      thumbnailUrl:
          'https://nos.wjv-1.neo.id/rspi-assets-production/rspi-api/uploads/MTcyNDI5MzA0OTE2MQ==.jpeg',
      heroAssetPath: 'assets/images/rspi_hero.jpg',
      bannerBottomText: 'PEMERIKSAAN KEPADATAN TULANG (BMD/DEXA)',
      sourceActionLabel: 'Baca Artikel Asli',
      sections: [
        ArticleSection(
          number: 1,
          title: 'Pengertian & Karakteristik Silent Disease',
          paragraphs: [
            'Osteoporosis adalah penyakit tulang sistemik yang ditandai dengan penurunan densitas atau kepadatan massa tulang, yang mengakibatkan tulang menjadi rapuh dan mudah patah. Penyakit ini umumnya dialami oleh wanita dan sering kali dimulai sejak memasuki masa menopause.',
            'Osteoporosis dijuluki sebagai "silent disease" karena umumnya berkembang tanpa menimbulkan keluhan atau gejala spesifik sebelum terjadinya patah tulang. Patah tulang akibat osteoporosis dapat terjadi secara tiba-tiba akibat benturan yang sebenarnya tergolong ringan (trivial trauma), seperti terjatuh saat berjalan biasa.',
          ],
        ),
        ArticleSection(
          number: 2,
          title: 'Faktor Risiko Osteoporosis',
          paragraphs: [
            'Meski penurunan massa tulang terjadi secara alami seiring usia, terdapat beberapa faktor penting yang dapat mempercepat terjadinya pengeroposan tulang menurut tinjauan medis RS Pondok Indah:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Faktor Penuaan, Hormon & Genetik',
              icon: Icons.person_search_rounded,
              iconColor: Color(0xFF358888),
              iconBgColor: Color(0xFFE6F3F3),
              bulletPoints: [
                'Proses Penuaan (Senilis): Puncak kepadatan tulang seseorang terjadi pada usia 35 tahun. Setelah masa ini, fungsi regenerasi tulang melambat dan kepadatan tulang mulai menyusut.',
                'Jenis Kelamin & Struktur Tulang: Wanita berisiko lebih tinggi karena secara anatomis memiliki ukuran tulang lebih kecil dan lebih tipis dibandingkan pria.',
                'Perubahan Hormon Menopause: Penurunan hormon estrogen secara drastis setelah menopause menyebabkan kepadatan tulang wanita menurun rata-rata 1,4% setiap 10 tahun.',
                'Riwayat Keluarga: Riwayat osteoporosis dalam keluarga meningkatkan risiko akibat kemiripan genetik, gaya hidup, dan pola diet harian.',
              ],
            ),
            ArticleInfoCard(
              title: 'Gaya Hidup & Kondisi Medis Sekunder',
              icon: Icons.health_and_safety_rounded,
              iconColor: Color(0xFFD97706),
              iconBgColor: Color(0xFFFEF3C7),
              bulletPoints: [
                'Gaya Hidup Sedenter: Kurangnya aktivitas fisik atau jarang berolahraga sejak usia muda mempercepat berkurangnya massa tulang.',
                'Konsumsi Alkohol & Rokok: Konsumsi alkohol berlebihan dan rokok mengganggu proses metabolisme kalsium.',
                'Penyakit Kronis: Penyakit yang menurunkan penyerapan kalsium di saluran cerna atau penyakit hormonal yang mengganggu keseimbangan estrogen/progesteron.',
                'Penggunaan Obat Jangka Panjang: Pemakaian obat golongan kortikosteroid oral dalam waktu lama.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 3,
          title: 'Pentingnya Skrining Dini & Frekuensi Pemeriksaan',
          paragraphs: [
            'Pemeriksaan osteoporosis secara rutin memungkinkan dokter mendeteksi penurunan kepadatan tulang sejak dini, sehingga intervensi medis dapat segera dilakukan sebelum terjadi komplikasi patah tulang yang fatal.',
            'Berikut rekomendasi frekuensi skrining osteoporosis dari RS Pondok Indah:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: 'Jadwal Skrining Kepadatan Tulang yang Dianjurkan',
              icon: Icons.calendar_month_rounded,
              iconColor: Color(0xFF358888),
              iconBgColor: Color(0xFFE6F3F3),
              bulletPoints: [
                'Wanita pascamenopause usia > 50 tahun: Disarankan skrining setiap 1–3 tahun sekali.',
                'Wanita berusia 65 tahun atau lebih: Disarankan skrining setahun sekali.',
                'Pria berusia 70 tahun atau lebih: Disarankan skrining setahun sekali.',
                'Usia lebih muda dengan faktor risiko tambahan: Pengguna obat kortikosteroid, riwayat patah tulang dini, atau kelainan metabolisme tulang disarankan skrining lebih awal.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 4,
          title: 'Metode Pemeriksaan BMD / DEXA',
          paragraphs: [
            'Gold standard (standar emas) pemeriksaan kepadatan tulang adalah pemeriksaan Bone Mineral Densitometry (BMD) yang dilakukan dengan metode Dual Energy X-ray Absorptiometry (DEXA).',
            'Saat pemeriksaan BMD, terdapat 3 titik utama yang menjadi fokus evaluasi karena paling sering mengalami penurunan kepadatan tulang: leher tulang paha (neck femur), tulang belakang lumbal (tulang pinggang), dan pergelangan tangan.',
          ],
          diagnosisBox: ArticleDiagnosisBox(
            introText:
                'Interpretasi hasil pemeriksaan BMD dilaporkan dalam parameter T-Score (membandingkan kondisi tulang dengan orang muda yang sehat):',
            procedures: [
              DiagnosisItem(
                name: 'Leher Tulang Paha (Neck Femur)',
                description: 'Paling krusial untuk mencegah fraktur panggul yang berisiko komplikasi berat',
              ),
              DiagnosisItem(
                name: 'Tulang Belakang Lumbal (Pinggang)',
                description: 'Mendeteksi penipisan tulang penyangga punggung dan mencegah bungkuk',
              ),
              DiagnosisItem(
                name: 'Pergelangan Tangan (Radius)',
                description: 'Area yang paling sering mengalami fraktur saat refleks menahan jatuh',
              ),
            ],
            tScores: [
              TScoreItem(scoreRange: '> -1.0', status: 'Normal (Kepadatan Tulang Sehat)'),
              TScoreItem(
                scoreRange: '-1.0 s/d -2.5',
                status: 'Osteopenia (Ambang Kuning / Awal Menuju Osteoporosis)',
              ),
              TScoreItem(
                scoreRange: '< -2.5',
                status: 'Osteoporosis (Ambang Merah / Tulang Rapuh)',
              ),
            ],
          ),
          infoCards: [
            ArticleInfoCard(
              title: 'Perbedaan Skor T dan Skor Z',
              icon: Icons.insights_rounded,
              iconColor: Color(0xFF358888),
              iconBgColor: Color(0xFFE6F3F3),
              bulletPoints: [
                'Skor T (T-Score): Membandingkan kepadatan mineral tulang Anda dengan kepadatan puncak orang dewasa muda yang sehat.',
                'Skor Z (Z-Score): Membandingkan kepadatan tulang Anda dengan populasi sebaya berdasarkan kelompok usia, jenis kelamin, dan latar belakang etnis.',
              ],
            ),
          ],
        ),
        ArticleSection(
          number: 5,
          title: 'Cara Menjaga Kesehatan Tulang & Pencegahan Fraktur',
          paragraphs: [
            'Bagi Anda yang hasil pemeriksaannya telah memasuki ambang batas kuning (osteopenia) maupun merah (osteoporosis), langkah-langkah berikut sangat krusial untuk mencegah penurunan massa tulang lebih lanjut:',
          ],
          infoCards: [
            ArticleInfoCard(
              title: '4 Langkah Pengelolaan Tulang Rekomendasi RSPI',
              icon: Icons.checklist_rounded,
              iconColor: Color(0xFF358888),
              iconBgColor: Color(0xFFE6F3F3),
              bulletPoints: [
                'Perhatikan Asupan Nutrisi: Konsumsi kalsium minimal 1.200 mg dan vitamin D 800 IU per hari bagi usia lanjut untuk mempertahankan kepadatan massa tulang.',
                'Olahraga Rutin Terarah: Berdasarkan Teori Wolff, kepadatan tulang akan meningkat pada orang yang rutin berolahraga. Hindari olahraga berisiko kontak fisik untuk mencegah jatuh atau benturan keras.',
                'Jalani Terapi Obat Khusus: Bila sudah masuk kategori osteoporosis, dokter spesialis ortopedi akan meresepkan terapi farmakologis untuk menghambat laju penyerapan tulang.',
                'Tes Berkala Rutin: Lakukan evaluasi BMD secara berkala agar efektivitas terapi dan kondisi tulang terpantau dengan baik.',
              ],
            ),
            ArticleInfoCard(
              isAlert: true,
              title: 'Pertolongan Pertama Ketika Terjatuh',
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFDC2626),
              iconBgColor: Color(0xFFFEE2E2),
              bulletPoints: [
                'Jangan banyak bergerak saat terjatuh untuk mencegah pergeseran tulang.',
                'Hindari terapi tradisional seperti pijat atau urut, karena berisiko memperparah cedera tulang dan jaringan sekitar.',
                'Jangan berasumsi pasti harus operasi; dokter spesialis ortopedi akan menentukan solusi terbaik, termasuk opsi imobilisasi atau tirah baring.',
                'Segera hubungi fasilitas kesehatan terdekat untuk evaluasi ada/tidaknya fraktur tersembunyi.',
              ],
            ),
          ],
          doctorConsultation: ArticleDoctorConsultation(
            text:
                'Jika Anda memiliki faktor risiko pengeroposan tulang atau ingin memeriksakan kepadatan tulang Anda, jangan ragu untuk berkonsultasi dengan dokter spesialis ortopedi di RS Pondok Indah yang didukung fasilitas medis berteknologi mutakhir.',
            highlightedSource: 'RS PONDOK INDAH',
            consultationUrl:
                'https://www.rspondokindah.co.id/id/news/deteksi-dan-cegah-osteoporosis',
          ),
        ),
      ],
    ),
  ];
}

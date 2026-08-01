// scripts/seed_data.js
// Run once to populate sample news, alerts, and a tip for demoing.

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function seed() {
  const now = Timestamp.now();

  const news = [
    {
      title: 'Mahendra Chowk road repair to begin next week',
      body: 'The Birtamode municipality has confirmed repair work on the damaged stretch near Mahendra Chowk will start Monday, expected to take five days.',
      imageUrl: null,
      category: 'local',
      authorName: 'BirtaKhabar Desk',
      authorId: 'seed',
      publishedAt: now,
      isVerified: true,
      viewCount: 0,
    },
    {
      title: 'Jhapa cricket team advances to provincial finals',
      body: 'The Jhapa district cricket team beat Ilam by 6 wickets in yesterday\'s semifinal, securing a spot in the provincial finals next month.',
      imageUrl: null,
      category: 'sports',
      authorName: 'BirtaKhabar Desk',
      authorId: 'seed',
      publishedAt: now,
      isVerified: true,
      viewCount: 0,
    },
    {
      title: 'New cold storage facility opens for local vegetable farmers',
      body: 'A cooperative-run cold storage facility opened this week near Birtamode, aimed at reducing post-harvest losses for area vegetable farmers.',
      imageUrl: null,
      category: 'business',
      authorName: 'BirtaKhabar Desk',
      authorId: 'seed',
      publishedAt: now,
      isVerified: true,
      viewCount: 0,
    },
  ];

  const alerts = [
    {
      title: 'Heavy rainfall warning for Jhapa district',
      description: 'The Department of Hydrology and Meteorology has issued a heavy rainfall alert for Jhapa district over the next 48 hours. Residents near the Mai and Kankai rivers should stay alert.',
      location: 'Jhapa District',
      severity: 'warning',
      postedBy: 'BirtaKhabar Admin',
      postedAt: now,
      isActive: true,
    },
  ];

  const tips = [
    {
      title: 'Streetlight out near Ward 4 market',
      description: 'The streetlight at the Ward 4 market entrance has been out for about a week, making it hard to see after dark.',
      imageUrl: null,
      submittedByName: 'Local Resident',
      submittedByUid: 'seed-resident',
      contactPhone: null,
      submittedAt: now,
      status: 'pending',
      reviewNote: null,
    },
  ];

  for (const article of news) {
    await db.collection('news').add(article);
  }
  for (const alert of alerts) {
    await db.collection('alerts').add(alert);
  }
  for (const tip of tips) {
    await db.collection('newsTips').add(tip);
  }

  console.log(`Seeded ${news.length} news articles, ${alerts.length} alerts, ${tips.length} tips.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
export const COLORS = {
  primary: '#FFD600',
  secondary: '#00BCD4',
  action: '#4CAF50',
  background: '#1A1A1A',
  surface: '#2A2A2A',
  surfaceElevated: '#333333',
  error: '#F44336',
  textPrimary: '#FFFFFF',
  textSecondary: '#B0B0B0',
  textOnLight: '#1A1A1A',
  blue: '#1565C0',
};

export const SPACING = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const RADIUS = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
};

export const TRADE_TYPES = [
  'clothing', 'food', 'electronics', 'furniture', 'jewelry', 'household', 'toys', 'other',
] as const;

export const TRADE_TYPE_LABELS: Record<string, { ar: string; fr: string }> = {
  clothing: { ar: '\u0645\u0644\u0627\u0628\u0633', fr: 'V\u00eatements' },
  food: { ar: '\u0645\u0648\u0627\u062f \u063a\u0630\u0627\u0626\u064a\u0629', fr: 'Alimentation' },
  electronics: { ar: '\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a\u0627\u062a', fr: '\u00c9lectronique' },
  furniture: { ar: '\u0623\u062b\u0627\u062b', fr: 'Meubles' },
  jewelry: { ar: '\u0645\u062c\u0648\u0647\u0631\u0627\u062a', fr: 'Bijoux' },
  household: { ar: '\u0623\u062f\u0648\u0627\u062a \u0645\u0646\u0632\u0644\u064a\u0629', fr: 'Articles m\u00e9nagers' },
  toys: { ar: '\u0623\u0644\u0639\u0627\u0628', fr: 'Jouets' },
  other: { ar: '\u0623\u062e\u0631\u0649', fr: 'Autres' },
};

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Locale = 'ar' | 'fr';

interface Translations {
  [key: string]: string;
}

const ar: Translations = {
  appName: '\u062d\u0648\u0627\u0646\u062a\u064a',
  home: '\u0627\u0644\u0631\u0626\u064a\u0633\u064a\u0629',
  filter: '\u062a\u0635\u0641\u064a\u0629',
  favorites: '\u0627\u0644\u0645\u0641\u0636\u0644\u0629',
  notifications: '\u0625\u0634\u0639\u0627\u0631\u0627\u062a',
  profile: '\u0627\u0644\u0645\u0644\u0641',
  login: '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644',
  signup: '\u0625\u0646\u0634\u0627\u0621 \u062d\u0633\u0627\u0628',
  email: '\u0627\u0644\u0628\u0631\u064a\u062f \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a',
  password: '\u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
  confirmPassword: '\u062a\u0623\u0643\u064a\u062f \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
  name: '\u0627\u0644\u0627\u0633\u0645',
  merchant: '\u062a\u0627\u062c\u0631',
  visitor: '\u062d\u0631\u064a\u0641',
  haveAccount: '\u0644\u062f\u064a\u0643 \u062d\u0633\u0627\u0628\u061f',
  noAccount: '\u0644\u064a\u0633 \u0644\u062f\u064a\u0643 \u062d\u0633\u0627\u0628\u061f',
  governorate: '\u0627\u0644\u0648\u0644\u0627\u064a\u0629',
  delegation: '\u0627\u0644\u0645\u0639\u062a\u0645\u062f\u064a\u0629',
  tradeType: '\u0646\u0648\u0639 \u0627\u0644\u062a\u062c\u0627\u0631\u0629',
  theMerchant: '\u0627\u0644\u062a\u0627\u062c\u0631',
  search: '\u0628\u062d\u062b',
  shopName: '\u0627\u0633\u0645 \u0627\u0644\u0645\u062a\u062c\u0631',
  phone: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
  save: '\u062d\u0641\u0638',
  cancel: '\u0625\u0644\u063a\u0627\u0621',
  logout: '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c',
  setupShop: '\u0625\u0639\u062f\u0627\u062f \u0627\u0644\u0645\u062a\u062c\u0631',
  addProduct: '\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062a\u062c',
  myProducts: '\u0645\u0646\u062a\u062c\u0627\u062a\u064a',
  productName: '\u0627\u0633\u0645 \u0627\u0644\u0645\u0646\u062a\u062c',
  price: '\u0627\u0644\u0633\u0639\u0631',
  description: '\u0627\u0644\u0648\u0635\u0641',
  expiryDate: '\u062a\u0627\u0631\u064a\u062e \u0627\u0644\u0627\u0646\u062a\u0647\u0627\u0621',
  publish: '\u0646\u0634\u0631',
  available: '\u0645\u062a\u0648\u0641\u0631',
  expired: '\u0645\u0646\u062a\u0647\u064a',
  call: '\u0627\u062a\u0635\u0644',
  report: '\u0625\u0628\u0644\u0627\u063a',
  follow: '\u0645\u062a\u0627\u0628\u0639\u0629',
  unfollow: '\u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u0645\u062a\u0627\u0628\u0639\u0629',
  noFavorites: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0641\u0636\u0644\u0627\u062a',
  noProducts: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0646\u062a\u062c\u0627\u062a',
  noNotifications: '\u0644\u0627 \u062a\u0648\u062c\u062f \u0625\u0634\u0639\u0627\u0631\u0627\u062a',
  follows: '\u0645\u062a\u0627\u0628\u0639\u0627\u062a',
  apply: '\u062a\u0637\u0628\u064a\u0642',
  clear: '\u0645\u0633\u062d',
  stats: '\u0627\u0644\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a',
  totalVisitors: '\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0632\u0648\u0627\u0631',
  views: '\u0645\u0634\u0627\u0647\u062f\u0627\u062a',
  editShop: '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u062a\u062c\u0631',
  tnd: '\u062f.\u062a',
  langToggle: 'FR',
  counterfeit: '\u0645\u0646\u062a\u062c\u0627\u062a \u0645\u0632\u064a\u0641\u0629',
  fraud: '\u0627\u062d\u062a\u064a\u0627\u0644',
  inappropriate: '\u0645\u062d\u062a\u0648\u0649 \u063a\u064a\u0631 \u0644\u0627\u0626\u0642',
  other: '\u0623\u062e\u0631\u0649',
  reportReason: '\u0633\u0628\u0628 \u0627\u0644\u0625\u0628\u0644\u0627\u063a',
  details: '\u062a\u0641\u0627\u0635\u064a\u0644',
  send: '\u0625\u0631\u0633\u0627\u0644',
  reportSent: '\u062a\u0645 \u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0625\u0628\u0644\u0627\u063a',
  selectImages: '\u0627\u062e\u062a\u064a\u0627\u0631 \u0627\u0644\u0635\u0648\u0631',
  loading: '\u062c\u0627\u0631\u064a \u0627\u0644\u062a\u062d\u0645\u064a\u0644...',
  error: '\u062e\u0637\u0623',
  retry: '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629',
  delete: '\u062d\u0630\u0641',
  edit: '\u062a\u0639\u062f\u064a\u0644',
};

const fr: Translations = {
  appName: 'Hwenti',
  home: 'Accueil',
  filter: 'Filtrer',
  favorites: 'Favoris',
  notifications: 'Notifications',
  profile: 'Profil',
  login: 'Se connecter',
  signup: 'Cr\u00e9er un compte',
  email: 'E-mail',
  password: 'Mot de passe',
  confirmPassword: 'Confirmer le mot de passe',
  name: 'Nom',
  merchant: 'Marchand',
  visitor: 'Client',
  haveAccount: 'D\u00e9j\u00e0 inscrit ?',
  noAccount: 'Pas de compte ?',
  governorate: 'Gouvernorat',
  delegation: 'D\u00e9l\u00e9gation',
  tradeType: 'Type de commerce',
  theMerchant: 'Marchand',
  search: 'Rechercher',
  shopName: 'Nom du magasin',
  phone: 'T\u00e9l\u00e9phone',
  save: 'Enregistrer',
  cancel: 'Annuler',
  logout: 'D\u00e9connexion',
  setupShop: 'Configuration du magasin',
  addProduct: 'Ajouter un produit',
  myProducts: 'Mes produits',
  productName: 'Nom du produit',
  price: 'Prix',
  description: 'Description',
  expiryDate: "Date d'expiration",
  publish: 'Publier',
  available: 'Disponible',
  expired: 'Expir\u00e9',
  call: 'Appeler',
  report: 'Signaler',
  follow: 'Suivre',
  unfollow: 'Ne plus suivre',
  noFavorites: 'Aucun favori',
  noProducts: 'Aucun produit',
  noNotifications: 'Aucune notification',
  follows: 'Suivis',
  apply: 'Appliquer',
  clear: 'Effacer',
  stats: 'Statistiques',
  totalVisitors: 'Total visiteurs',
  views: 'Vues',
  editShop: 'Modifier le magasin',
  tnd: 'TND',
  langToggle: '\u0639',
  counterfeit: 'Produits contrefaits',
  fraud: 'Fraude',
  inappropriate: 'Contenu inappropri\u00e9',
  other: 'Autre',
  reportReason: 'Raison du signalement',
  details: 'D\u00e9tails',
  send: 'Envoyer',
  reportSent: 'Signalement envoy\u00e9',
  selectImages: 'S\u00e9lectionner des images',
  loading: 'Chargement...',
  error: 'Erreur',
  retry: 'R\u00e9essayer',
  delete: 'Supprimer',
  edit: 'Modifier',
};

const translations = { ar, fr };

interface LocaleContextType {
  locale: Locale;
  t: (key: string) => string;
  toggleLocale: () => void;
  isRTL: boolean;
}

const LocaleContext = createContext<LocaleContextType>({
  locale: 'ar',
  t: (key: string) => key,
  toggleLocale: () => {},
  isRTL: true,
});

export function LocaleProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocale] = useState<Locale>('ar');

  useEffect(() => {
    AsyncStorage.getItem('locale').then((saved) => {
      if (saved === 'ar' || saved === 'fr') setLocale(saved);
    }).catch(() => {});
  }, []);

  const toggleLocale = useCallback(() => {
    const next = locale === 'ar' ? 'fr' : 'ar';
    setLocale(next);
    AsyncStorage.setItem('locale', next).catch(() => {});
  }, [locale]);

  const t = useCallback((key: string) => {
    return translations[locale]?.[key] ?? key;
  }, [locale]);

  const isRTL = locale === 'ar';

  return (
    <LocaleContext.Provider value={{ locale, t, toggleLocale, isRTL }}>
      {children}
    </LocaleContext.Provider>
  );
}

export function useLocale() {
  return useContext(LocaleContext);
}

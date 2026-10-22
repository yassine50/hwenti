import React, { useState } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet, ScrollView, Image, Alert, Platform, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { productsControllerCreate, uploadControllerPresigned, uploadControllerComplete } from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';

export default function AddProductScreen() {
  const { t, locale } = useLocale();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [phone, setPhone] = useState('');
  const [description, setDescription] = useState('');
  const [expiryDays, setExpiryDays] = useState('30');
  const [images, setImages] = useState<{ uri: string; fileId?: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const pickImages = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsMultipleSelection: true,
      quality: 0.7,
    });
    if (!result.canceled && result.assets?.length) {
      setImages(prev => [...prev, ...result.assets.map(a => ({ uri: a.uri }))]);
    }
  };

  const uploadImage = async (uri: string): Promise<string> => {
    const fileName = uri.split('/').pop() ?? `img_${Date.now()}.jpg`;
    const contentType = 'image/jpeg';
    const presigned = await uploadControllerPresigned({ fileName, contentType, isPublic: true });
    const uploadUrl = presigned?.uploadUrl ?? '';
    const cloudPath = presigned?.cloud_storage_path ?? '';

    const fileResp = await fetch(uri);
    const blob = await fileResp.blob();
    await fetch(uploadUrl, { method: 'PUT', body: blob, headers: { 'Content-Type': contentType } });

    const completed = await uploadControllerComplete({ cloud_storage_path: cloudPath, fileName, contentType });
    return completed?.id ?? '';
  };

  const handlePublish = async () => {
    if (!name?.trim() || !price?.trim() || !phone?.trim()) {
      setError(locale === 'ar' ? 'الرجاء ملء الحقول المطلوبة' : 'Veuillez remplir les champs requis');
      return;
    }
    setLoading(true);
    setError('');
    try {
      // Upload images first
      const fileIds: string[] = [];
      for (const img of images) {
        if (img?.fileId) {
          fileIds.push(img.fileId);
        } else {
          const fid = await uploadImage(img?.uri ?? '');
          if (fid) fileIds.push(fid);
        }
      }
      const days = parseInt(expiryDays, 10) || 30;
      const expiry = new Date();
      expiry.setDate(expiry.getDate() + days);

      await productsControllerCreate({
        name: name.trim(),
        price: parseFloat(price) || 0,
        phone: phone.trim(),
        description: description?.trim() || undefined,
        expiryDate: expiry.toISOString(),
        imageFileIds: fileIds,
      });
      router.back();
    } catch (e) {
      setError(getErrorMessage(e, 'Failed'));
    } finally {
      setLoading(false);
    }
  };

  const removeImage = (idx: number) => {
    setImages(prev => prev.filter((_, i) => i !== idx));
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} />
        </Pressable>
        <Text style={styles.headerTitle}>{t('addProduct')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        {!!error && <Text style={styles.errorText}>{error}</Text>}

        <Text style={styles.label}>{t('productName')} *</Text>
        <TextInput style={styles.input} value={name} onChangeText={setName} placeholder={t('productName')} placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('price')} (TND) *</Text>
        <TextInput style={styles.input} value={price} onChangeText={setPrice} placeholder="0.00" placeholderTextColor={COLORS.textSecondary} keyboardType="decimal-pad" />

        <Text style={styles.label}>{t('phone')} *</Text>
        <TextInput style={styles.input} value={phone} onChangeText={setPhone} placeholder="+216..." placeholderTextColor={COLORS.textSecondary} keyboardType="phone-pad" />

        <Text style={styles.label}>{t('description')}</Text>
        <TextInput style={[styles.input, { minHeight: 80, textAlignVertical: 'top' }]} value={description} onChangeText={setDescription} placeholder={t('description')} placeholderTextColor={COLORS.textSecondary} multiline />

        <Text style={styles.label}>{t('expiryDate')} ({locale === 'ar' ? 'أيام' : 'jours'})</Text>
        <TextInput style={styles.input} value={expiryDays} onChangeText={setExpiryDays} placeholder="30" placeholderTextColor={COLORS.textSecondary} keyboardType="number-pad" />

        <Text style={styles.label}>{t('selectImages')}</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.imageRow}>
          <Pressable style={styles.addImageBtn} onPress={pickImages}>
            <Ionicons name="camera-outline" size={32} color={COLORS.textSecondary} />
          </Pressable>
          {(images ?? []).map((img, idx) => (
            <View key={idx} style={styles.imgWrapper}>
              <Image source={{ uri: img?.uri }} style={styles.imgThumb} />
              <Pressable style={styles.removeImg} onPress={() => removeImage(idx)}>
                <Ionicons name="close-circle" size={22} color={COLORS.error} />
              </Pressable>
            </View>
          ))}
        </ScrollView>

        <Pressable style={[styles.publishBtn, loading && { opacity: 0.6 }]} onPress={handlePublish} disabled={loading}>
          {loading ? <ActivityIndicator color="#fff" /> : (
            <><Ionicons name="cloud-upload-outline" size={22} color="#fff" /><Text style={styles.publishText}>{t('publish')}</Text></>
          )}
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: SPACING.md },
  backBtn: { padding: SPACING.xs },
  headerTitle: { fontSize: 20, fontWeight: 'bold', color: COLORS.textOnLight },
  content: { padding: SPACING.md, paddingBottom: 60 },
  label: { color: COLORS.textPrimary, fontSize: 15, fontWeight: '600', marginTop: SPACING.md, marginBottom: SPACING.xs },
  input: { backgroundColor: COLORS.surface, color: COLORS.textPrimary, borderRadius: RADIUS.md, padding: SPACING.md, fontSize: 16 },
  imageRow: { marginTop: SPACING.sm },
  addImageBtn: { width: 80, height: 80, backgroundColor: COLORS.surface, borderRadius: RADIUS.md, justifyContent: 'center', alignItems: 'center', marginRight: SPACING.sm, borderWidth: 1, borderColor: COLORS.textSecondary, borderStyle: 'dashed' },
  imgWrapper: { position: 'relative', marginRight: SPACING.sm },
  imgThumb: { width: 80, height: 80, borderRadius: RADIUS.md },
  removeImg: { position: 'absolute', top: -6, right: -6 },
  publishBtn: { backgroundColor: COLORS.action, borderRadius: RADIUS.md, padding: SPACING.md, alignItems: 'center', marginTop: SPACING.xl, flexDirection: 'row', justifyContent: 'center', gap: SPACING.sm },
  publishText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  errorText: { color: COLORS.error, fontSize: 14, textAlign: 'center', marginBottom: SPACING.sm },
});

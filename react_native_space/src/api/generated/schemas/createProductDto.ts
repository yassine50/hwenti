// @ts-nocheck

export interface CreateProductDto {
  name: string;
  price: number;
  phone: string;
  description?: string;
  expiryDate: string;
  publishDate?: string;
  imageFileIds: string[];
}

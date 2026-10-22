import { IsString, IsNumber, IsOptional, IsArray, IsDateString, Min, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @IsString()
  name: string;

  @IsNumber()
  @Min(0)
  price: number;

  @IsString()
  phone: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  expiryDate: string;

  @IsDateString()
  @IsOptional()
  publishDate?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(6)
  @IsString({ each: true })
  imageFileIds: string[];
}

export class UpdateProductDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsNumber()
  @Min(0)
  @IsOptional()
  price?: number;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  @IsOptional()
  expiryDate?: string;

  @IsDateString()
  @IsOptional()
  publishDate?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(6)
  @IsString({ each: true })
  @IsOptional()
  imageFileIds?: string[];
}

export class ProductImageDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  fileId: string;

  @ApiProperty()
  url: string;

  @ApiProperty()
  isPrimary: boolean;

  @ApiProperty()
  sortOrder: number;
}

export class ProductMerchantDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ nullable: true })
  shopName: string | null;

  @ApiProperty()
  averageRating: number;

  @ApiProperty({ nullable: true })
  logoFileId: string | null;

  @ApiProperty({ nullable: true })
  logoUrl: string | null;
}

export class ProductDetailResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  price: number;

  @ApiProperty()
  phone: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty()
  expiryDate: string;

  @ApiProperty()
  publishDate: string;

  @ApiProperty()
  viewCount: number;

  @ApiProperty()
  isAvailable: boolean;

  @ApiProperty({ type: () => ProductMerchantDto })
  merchant: ProductMerchantDto;

  @ApiProperty({ type: () => [ProductImageDto] })
  images: ProductImageDto[];

  @ApiProperty()
  isFavorited: boolean;

  @ApiProperty()
  createdAt: string;
}

export class ProductListItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  price: number;

  @ApiProperty()
  phone: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty()
  expiryDate: string;

  @ApiProperty()
  publishDate: string;

  @ApiProperty()
  viewCount: number;

  @ApiProperty()
  isAvailable: boolean;

  @ApiProperty({ type: () => ProductMerchantDto })
  merchant: ProductMerchantDto;

  @ApiProperty({ nullable: true })
  primaryImageUrl: string | null;

  @ApiProperty()
  imageCount: number;

  @ApiProperty()
  isFavorited: boolean;

  @ApiProperty()
  createdAt: string;
}

export class ProductListResponseDto {
  @ApiProperty({ type: () => [ProductListItemDto] })
  items: ProductListItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  totalPages: number;
}

export class ViewCountResponseDto {
  @ApiProperty()
  viewCount: number;
}

export class SuccessResponseDto {
  @ApiProperty()
  success: boolean;
}

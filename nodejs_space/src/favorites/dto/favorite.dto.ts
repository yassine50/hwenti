import { ApiProperty } from '@nestjs/swagger';
import { ProductListItemDto } from '../../products/dto/product.dto';

export class FavoriteSuccessDto {
  @ApiProperty()
  success: boolean;
}

export class FavoriteListResponseDto {
  @ApiProperty({ type: () => [ProductListItemDto] })
  items: ProductListItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  totalPages: number;
}

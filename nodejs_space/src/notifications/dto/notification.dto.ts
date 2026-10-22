import { ApiProperty } from '@nestjs/swagger';

export class NotificationItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  type: string;

  @ApiProperty()
  message: string;

  @ApiProperty({ nullable: true })
  productId: string | null;

  @ApiProperty()
  merchantId: string;

  @ApiProperty({ nullable: true })
  merchantName: string | null;

  @ApiProperty({ nullable: true })
  merchantLogoUrl: string | null;

  @ApiProperty()
  isRead: boolean;

  @ApiProperty()
  createdAt: string;
}

export class NotificationListResponseDto {
  @ApiProperty({ type: () => [NotificationItemDto] })
  items: NotificationItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  page: number;

  @ApiProperty()
  totalPages: number;
}

export class NotificationReadResponseDto {
  @ApiProperty()
  success: boolean;
}

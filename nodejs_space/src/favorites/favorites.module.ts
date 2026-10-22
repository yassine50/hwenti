import { Module } from '@nestjs/common';
import { FavoritesController } from './favorites.controller';
import { ProductsModule } from '../products/products.module';

@Module({
  imports: [ProductsModule],
  controllers: [FavoritesController],
})
export class FavoritesModule {}

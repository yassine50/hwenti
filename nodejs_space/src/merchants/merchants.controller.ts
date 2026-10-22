import { Controller, Post, Patch, Get, Body, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import type { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { MerchantsService } from './merchants.service';
import { MerchantSetupDto, MerchantUpdateDto, MerchantResponseDto, MerchantListResponseDto } from './dto/merchant.dto';

@Controller('api/merchants')
export class MerchantsController {
  constructor(private merchantsService: MerchantsService) {}

  @Post('setup')
  @UseGuards(JwtAuthGuard)
  async setup(@Body() dto: MerchantSetupDto, @Req() req: Request): Promise<MerchantResponseDto> {
    const user = req.user as { id: string };
    return this.merchantsService.setup(user.id, dto);
  }

  @Patch('me')
  @UseGuards(JwtAuthGuard)
  async updateMe(@Body() dto: MerchantUpdateDto, @Req() req: Request): Promise<MerchantResponseDto> {
    const user = req.user as { id: string };
    return this.merchantsService.updateMe(user.id, dto);
  }

  @Get()
  async findAll(
    @Query('governorateId') governorateId?: string,
    @Query('delegationId') delegationId?: string,
    @Query('tradeType') tradeType?: string,
    @Query('search') search?: string,
    @Query('page', new ParseIntPipe({ optional: true })) page?: number,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ): Promise<MerchantListResponseDto> {
    return this.merchantsService.findAll({ governorateId, delegationId, tradeType, search, page, limit });
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async findMe(@Req() req: Request): Promise<MerchantResponseDto> {
    const user = req.user as { id: string };
    return this.merchantsService.findMe(user.id);
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<MerchantResponseDto> {
    return this.merchantsService.findOne(id);
  }
}

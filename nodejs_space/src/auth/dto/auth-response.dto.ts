import { ApiProperty } from '@nestjs/swagger';

export class AuthUserDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  role: string;

  @ApiProperty()
  merchantSetupComplete: boolean;
}

export class AuthResponseDto {
  @ApiProperty()
  token: string;

  @ApiProperty({ type: () => AuthUserDto })
  user: AuthUserDto;
}

export class MeResponseDto {
  @ApiProperty({ type: () => AuthUserDto })
  user: AuthUserDto;
}

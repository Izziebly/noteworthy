import { IsString, MinLength, MaxLength } from 'class-validator';

export class CreateNoteDto {
  @IsString()
  @MinLength(1, { message: 'Title is required' })
  @MaxLength(120, { message: 'Title must not exceed 120 characters' })
  title: string;

  @IsString()
  @MinLength(1, { message: 'Content is required' })
  content: string;
}

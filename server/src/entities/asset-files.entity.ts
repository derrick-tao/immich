import { AssetEntity } from 'src/entities/asset.entity';
import { AssetFileType } from 'src/enum';
import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';

@Unique('UQ_assetId_type', ['assetId', 'type'])
@Entity('asset_files')
export class AssetFileEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index('IDX_asset_files_assetId')
  @Column()
  assetId!: string;

  @ManyToOne(() => AssetEntity, { onDelete: 'CASCADE', onUpdate: 'CASCADE' })
  asset?: AssetEntity;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;

  @Column()
  type!: AssetFileType;

  @Column()
  path!: string;
}
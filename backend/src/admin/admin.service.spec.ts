import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException } from '@nestjs/common';
import { AdminService } from './admin.service';
import { User } from '../users/entities/user.entity';
import { UserRole } from '../common/enums/user.enum';

describe('AdminService', () => {
  let service: AdminService;

  const mockUserRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
    count: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdminService,
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<AdminService>(AdminService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllUsers', () => {
    it('should return paginated users', async () => {
      const users = [
        { id: '1', email: 'user1@example.com', fullName: 'User One', role: UserRole.USER, isActive: true, createdAt: new Date() },
        { id: '2', email: 'user2@example.com', fullName: 'User Two', role: UserRole.USER, isActive: false, createdAt: new Date() },
      ];

      const queryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([users, 2]),
      };

      mockUserRepository.createQueryBuilder.mockReturnValue(queryBuilder);

      const result = await service.getAllUsers(undefined, undefined, 1, 10);

      expect(result.data).toEqual([
        {
          id: '1',
          email: 'user1@example.com',
          fullName: 'User One',
          role: UserRole.USER,
          isActive: true,
          createdAt: users[0].createdAt,
        },
        {
          id: '2',
          email: 'user2@example.com',
          fullName: 'User Two',
          role: UserRole.USER,
          isActive: false,
          createdAt: users[1].createdAt,
        },
      ]);
      expect(result.total).toBe(2);
      expect(result.page).toBe(1);
      expect(queryBuilder.skip).toHaveBeenCalledWith(0);
      expect(queryBuilder.take).toHaveBeenCalledWith(10);
    });

    it('should filter users by role', async () => {
      const queryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
      };

      mockUserRepository.createQueryBuilder.mockReturnValue(queryBuilder);

      await service.getAllUsers(UserRole.DOCTOR, undefined, 1, 10);

      expect(queryBuilder.where).toHaveBeenCalledWith('user.role = :role', { role: UserRole.DOCTOR });
    });

    it('should filter users by active status', async () => {
      const queryBuilder = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
      };

      mockUserRepository.createQueryBuilder.mockReturnValue(queryBuilder);

      await service.getAllUsers(undefined, true, 1, 10);

      expect(queryBuilder.andWhere).toHaveBeenCalledWith('user.isActive = :isActive', { isActive: true });
    });
  });

  describe('updateUserStatus', () => {
    it('should activate a user', async () => {
      const user = {
        id: '1',
        email: 'test@example.com',
        isActive: false,
      };

      mockUserRepository.findOne.mockResolvedValue(user);
      mockUserRepository.save.mockImplementation(async (entity) => entity);

      const result = await service.updateUserStatus('1', true);

      expect(result.isActive).toBe(true);
      expect(mockUserRepository.save).toHaveBeenCalledWith({ ...user, isActive: true });
    });

    it('should throw NotFoundException if user does not exist', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.updateUserStatus('missing', true)).rejects.toThrow(NotFoundException);
    });
  });

  describe('getUserDetails', () => {
    it('should return user details when user exists', async () => {
      const user = {
        id: '1',
        email: 'detail@example.com',
        fullName: 'Detail User',
        role: UserRole.USER,
        isActive: true,
        gender: 'MALE',
        createdAt: new Date(),
      };

      mockUserRepository.findOne.mockResolvedValue(user);

      const result = await service.getUserDetails('1');

      expect(result).toEqual({
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        isActive: user.isActive,
        gender: user.gender,
        createdAt: user.createdAt,
      });
    });

    it('should throw NotFoundException when user does not exist', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.getUserDetails('missing')).rejects.toThrow(NotFoundException);
    });
  });
});

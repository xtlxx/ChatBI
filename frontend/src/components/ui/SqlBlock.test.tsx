import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { SqlBlock } from './SqlBlock';

// Mock translation
vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

describe('SqlBlock Component', () => {
  it('renders SQL query text', () => {
    const mockSql = 'SELECT * FROM users;';
    render(<SqlBlock sql={mockSql} />);
    
    // Check if the SQL text is rendered
    expect(screen.getByText(/SELECT \* FROM users;/i)).toBeInTheDocument();
  });

  it('renders title from i18n', () => {
    render(<SqlBlock sql="SELECT 1;" />);
    expect(screen.getByText('sqlBlock.title')).toBeInTheDocument();
  });
});

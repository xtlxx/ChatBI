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
    const { container } = render(<SqlBlock sql={mockSql} />);
    
    // Check if the SQL text is rendered (ignoring HTML tags due to syntax highlighting)
    const preElement = container.querySelector('pre');
    expect(preElement).toBeInTheDocument();
    expect(preElement?.textContent).toBe('SELECT * FROM users;');
  });

  it('renders title from i18n', () => {
    render(<SqlBlock sql="SELECT 1;" />);
    expect(screen.getByText('sqlBlock.title')).toBeInTheDocument();
  });
});

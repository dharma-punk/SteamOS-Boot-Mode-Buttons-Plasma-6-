import { NavLink, Outlet } from 'react-router-dom';
import { TopBar } from '../components/TopBar';

interface AppShellProps {
  quickAddValue: string;
  onQuickAddValueChange: (value: string) => void;
  onQuickAdd: () => void;
}

const links = [
  { label: 'Today', to: '/' },
  { label: 'Calendar', to: '/calendar' },
  { label: 'All Tasks', to: '/tasks' },
  { label: 'Completed', to: '/completed' }
];

export function AppShell({ quickAddValue, onQuickAddValueChange, onQuickAdd }: AppShellProps) {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <h1>To-Do</h1>
        <nav>
          {links.map((link) => (
            <NavLink key={link.to} to={link.to} className={({ isActive }) => (isActive ? 'active' : '')} end={link.to === '/'}>
              {link.label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <main className="main-content">
        <TopBar
          quickAddValue={quickAddValue}
          onQuickAddValueChange={onQuickAddValueChange}
          onQuickAdd={onQuickAdd}
        />
        <Outlet />
      </main>
    </div>
  );
}

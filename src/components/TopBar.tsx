interface TopBarProps {
  quickAddValue: string;
  onQuickAddValueChange: (value: string) => void;
  onQuickAdd: () => void;
}

export function TopBar({ quickAddValue, onQuickAddValueChange, onQuickAdd }: TopBarProps) {
  return (
    <header className="topbar">
      <input
        aria-label="Quick add task"
        className="quick-add"
        placeholder="Quick add task and press Enter"
        value={quickAddValue}
        onChange={(event) => onQuickAddValueChange(event.target.value)}
        onKeyDown={(event) => {
          if (event.key === 'Enter') {
            onQuickAdd();
          }
        }}
      />
      <input aria-label="Search tasks" className="search" placeholder="Search tasks" />
      <select aria-label="Sort tasks" className="sort-select" defaultValue="priority">
        <option value="dueDate">Due date</option>
        <option value="priority">Priority</option>
        <option value="createdAt">Created</option>
      </select>
    </header>
  );
}

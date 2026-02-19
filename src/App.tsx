import { useState } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { AppShell } from './layout/AppShell';
import { AllTasksView } from './views/AllTasksView';
import { CalendarView } from './views/CalendarView';
import { CompletedView } from './views/CompletedView';
import { TodayView } from './views/TodayView';

export default function App() {
  const [quickAddValue, setQuickAddValue] = useState('');

  const handleQuickAdd = () => {
    const title = quickAddValue.trim();
    if (!title) {
      return;
    }

    // Placeholder until persistence layer is implemented in the next PR.
    console.info('Quick add task:', title);
    setQuickAddValue('');
  };

  return (
    <Routes>
      <Route
        path="/"
        element={
          <AppShell
            quickAddValue={quickAddValue}
            onQuickAddValueChange={setQuickAddValue}
            onQuickAdd={handleQuickAdd}
          />
        }
      >
        <Route index element={<TodayView />} />
        <Route path="calendar" element={<CalendarView />} />
        <Route path="tasks" element={<AllTasksView />} />
        <Route path="completed" element={<CompletedView />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}

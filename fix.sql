
ALTER TABLE time_entry
ADD CONSTRAINT fk_time_entry_assignment
FOREIGN KEY (task_id, employee_id)
REFERENCES task_assignment (task_id, employee_id)
ON DELETE RESTRICT;

CREATE OR REPLACE FUNCTION check_time_entry_assignment()
RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM task_assignment
        WHERE task_id = NEW.task_id
          AND employee_id = NEW.employee_id
          AND assigned_at::date <= NEW.work_date
    ) THEN
        RAISE EXCEPTION 'Сотрудник % не назначен на задачу % на дату % (назначение позже)',
            NEW.employee_id, NEW.task_id, NEW.work_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_time_entry_assignment
BEFORE INSERT OR UPDATE ON time_entry
FOR EACH ROW
EXECUTE FUNCTION check_time_entry_assignment();
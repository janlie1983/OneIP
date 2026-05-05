-- Permit Checklist Module
-- Tables: permit_templates, permit_items, user_checklists, checklist_progress

create table if not exists permit_templates (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  category text not null, -- 'factory_lease','land_use','eps','full_package'
  difficulty text not null default 'medium', -- 'easy','medium','hard'
  is_premium boolean not null default false,
  estimated_days int not null default 90,
  total_items int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists permit_items (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references permit_templates(id) on delete cascade,
  category text not null, -- 'registration','environment','fire_safety','construction','labor','tax'
  title text not null,
  description text,
  authority text,
  estimated_days int not null default 7,
  fee_vnd bigint,
  is_required boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists user_checklists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  template_id uuid not null references permit_templates(id),
  project_name text not null,
  company_name text,
  province text,
  status text not null default 'active', -- 'active','completed','archived'
  completed_items int not null default 0,
  total_items int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists checklist_progress (
  id uuid primary key default gen_random_uuid(),
  checklist_id uuid not null references user_checklists(id) on delete cascade,
  item_id uuid not null references permit_items(id) on delete cascade,
  status text not null default 'pending', -- 'pending','in_progress','done','skipped'
  notes text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table checklist_progress
  add constraint checklist_progress_unique unique (checklist_id, item_id);

-- RLS
alter table permit_templates enable row level security;
alter table permit_items enable row level security;
alter table user_checklists enable row level security;
alter table checklist_progress enable row level security;

create policy "anyone reads templates" on permit_templates for select using (true);
create policy "anyone reads items" on permit_items for select using (true);

create policy "users manage own checklists" on user_checklists
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "users manage own progress" on checklist_progress
  for all using (
    auth.uid() = (
      select user_id from user_checklists where id = checklist_id
    )
  )
  with check (
    auth.uid() = (
      select user_id from user_checklists where id = checklist_id
    )
  );

-- Trigger: keep user_checklists.completed_items in sync
create or replace function sync_checklist_counts()
returns trigger language plpgsql as $$
begin
  update user_checklists
  set
    completed_items = (
      select count(*) from checklist_progress
      where checklist_id = coalesce(new.checklist_id, old.checklist_id)
        and status = 'done'
    ),
    updated_at = now()
  where id = coalesce(new.checklist_id, old.checklist_id);
  return coalesce(new, old);
end;
$$;

create trigger trg_sync_checklist_counts
after insert or update or delete on checklist_progress
for each row execute function sync_checklist_counts();

-- Trigger: set total_items on user_checklists insert
create or replace function set_checklist_total_items()
returns trigger language plpgsql as $$
begin
  update user_checklists
  set total_items = (
    select count(*) from permit_items where template_id = (
      select template_id from user_checklists where id = new.id
    )
  )
  where id = new.id;
  return new;
end;
$$;

create trigger trg_set_checklist_total_items
after insert on user_checklists
for each row execute function set_checklist_total_items();

-- Seed: 3 templates
insert into permit_templates (id, name, description, category, difficulty, is_premium, estimated_days, total_items) values
(
  'aaaa0001-0000-0000-0000-000000000001',
  'Thuê nhà xưởng KCN',
  'Gói thủ tục cơ bản cho doanh nghiệp thuê nhà xưởng sẵn trong khu công nghiệp',
  'factory_lease', 'easy', false, 45, 6
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'Đăng ký quyền sử dụng đất',
  'Thủ tục đầy đủ để đăng ký quyền sử dụng đất công nghiệp 50 năm',
  'land_use', 'hard', true, 120, 6
),
(
  'aaaa0001-0000-0000-0000-000000000003',
  'Trọn gói FDI Greenfield',
  'Toàn bộ thủ tục từ đăng ký đầu tư đến vận hành nhà máy mới',
  'full_package', 'hard', true, 180, 5
);

-- Seed: permit items for template 1 (factory_lease)
insert into permit_items (template_id, category, title, description, authority, estimated_days, fee_vnd, is_required, sort_order) values
(
  'aaaa0001-0000-0000-0000-000000000001',
  'registration',
  'Đăng ký doanh nghiệp / Chi nhánh',
  'Đăng ký thành lập hoặc chi nhánh tại tỉnh có KCN',
  'Sở Kế hoạch và Đầu tư tỉnh',
  5, 200000, true, 1
),
(
  'aaaa0001-0000-0000-0000-000000000001',
  'registration',
  'Giấy chứng nhận đăng ký đầu tư (IRC)',
  'Cấp IRC cho dự án FDI tại Ban Quản lý KCN',
  'Ban Quản lý KCN tỉnh',
  15, 0, true, 2
),
(
  'aaaa0001-0000-0000-0000-000000000001',
  'environment',
  'Đăng ký kế hoạch bảo vệ môi trường',
  'Đăng ký KBVMT cho cơ sở sản xuất quy mô nhỏ',
  'UBND huyện / Ban Quản lý KCN',
  10, 0, true, 3
),
(
  'aaaa0001-0000-0000-0000-000000000001',
  'fire_safety',
  'Nghiệm thu phòng cháy chữa cháy',
  'Kiểm tra và nghiệm thu hệ thống PCCC nhà xưởng',
  'Cảnh sát PCCC tỉnh',
  7, 0, true, 4
),
(
  'aaaa0001-0000-0000-0000-000000000001',
  'labor',
  'Đăng ký nội quy lao động',
  'Đăng ký nội quy lao động tại Sở LĐTBXH',
  'Sở Lao động – Thương binh và Xã hội',
  5, 0, false, 5
),
(
  'aaaa0001-0000-0000-0000-000000000001',
  'tax',
  'Đăng ký thuế tại Chi cục thuế địa phương',
  'Đăng ký mã số thuế địa phương và khai thuế môn bài',
  'Chi cục Thuế quận/huyện',
  3, 300000, true, 6
);

-- Seed: permit items for template 2 (land_use)
insert into permit_items (template_id, category, title, description, authority, estimated_days, fee_vnd, is_required, sort_order) values
(
  'aaaa0001-0000-0000-0000-000000000002',
  'registration',
  'Quyết định chấp thuận chủ trương đầu tư',
  'Xin chấp thuận chủ trương đầu tư từ UBND tỉnh',
  'UBND tỉnh / Sở Kế hoạch và Đầu tư',
  30, 0, true, 1
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'registration',
  'Giấy chứng nhận đăng ký đầu tư (IRC)',
  'Cấp IRC cho dự án thuê đất tại KCN',
  'Ban Quản lý KCN tỉnh',
  15, 0, true, 2
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'environment',
  'Báo cáo đánh giá tác động môi trường (ĐTM)',
  'Lập và phê duyệt ĐTM cho dự án sản xuất quy mô lớn',
  'Bộ/Sở Tài nguyên và Môi trường',
  60, 50000000, true, 3
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'construction',
  'Giấy phép xây dựng nhà máy',
  'Xin phép xây dựng nhà máy, kho bãi trên đất thuê',
  'Sở Xây dựng tỉnh',
  30, 5000000, true, 4
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'fire_safety',
  'Thẩm duyệt thiết kế PCCC',
  'Thẩm duyệt thiết kế hệ thống PCCC trước khi xây dựng',
  'Cục Cảnh sát PCCC tỉnh',
  15, 0, true, 5
),
(
  'aaaa0001-0000-0000-0000-000000000002',
  'registration',
  'Hợp đồng thuê đất với KCN / UBND tỉnh',
  'Ký hợp đồng thuê đất 50 năm và nộp tiền thuê đất',
  'Ban Quản lý KCN / UBND tỉnh',
  10, 0, true, 6
);

-- Seed: permit items for template 3 (full_package FDI)
insert into permit_items (template_id, category, title, description, authority, estimated_days, fee_vnd, is_required, sort_order) values
(
  'aaaa0001-0000-0000-0000-000000000003',
  'registration',
  'Giấy chứng nhận đăng ký đầu tư (IRC) + ERC',
  'Cấp đồng thời IRC và Giấy chứng nhận đăng ký doanh nghiệp',
  'Ban Quản lý KCN / Sở KH&ĐT',
  21, 300000, true, 1
),
(
  'aaaa0001-0000-0000-0000-000000000003',
  'environment',
  'Giấy phép môi trường',
  'Cấp giấy phép môi trường tích hợp thay thế các loại giấy phép cũ',
  'Bộ/Sở Tài nguyên và Môi trường',
  90, 0, true, 2
),
(
  'aaaa0001-0000-0000-0000-000000000003',
  'construction',
  'Phê duyệt thiết kế xây dựng và cấp phép',
  'Phê duyệt thiết kế cơ sở, thiết kế kỹ thuật và cấp phép xây dựng',
  'Sở Xây dựng tỉnh',
  45, 10000000, true, 3
),
(
  'aaaa0001-0000-0000-0000-000000000003',
  'fire_safety',
  'Nghiệm thu PCCC và cấp giấy phép hoạt động',
  'Nghiệm thu toàn bộ hệ thống PCCC sau khi xây dựng hoàn thành',
  'Cục Cảnh sát PCCC',
  14, 0, true, 4
),
(
  'aaaa0001-0000-0000-0000-000000000003',
  'labor',
  'Đăng ký thang bảng lương và thỏa ước lao động',
  'Đăng ký hệ thống lương và ký thỏa ước lao động tập thể',
  'Sở Lao động – Thương binh và Xã hội',
  10, 0, false, 5
);

-- Update total_items counts (done manually since trigger fires on user_checklists insert, not template)
update permit_templates set total_items = (
  select count(*) from permit_items where template_id = permit_templates.id
);

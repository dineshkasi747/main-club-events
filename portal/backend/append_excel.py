import zipfile
import xml.etree.ElementTree as ET
import os
import sys

def append_to_hackathon_excel(excel_path, roll_number, full_name, current_year, branch, college_name, email, mobile_number, domain, mode, team_name=""):
    if not os.path.exists(excel_path):
        print(f"File not found: {excel_path}", file=sys.stderr)
        return False

    with zipfile.ZipFile(excel_path, 'r') as z:
        shared_xml = z.read('xl/sharedStrings.xml')
        sheet_xml = z.read('xl/worksheets/sheet1.xml')
        zip_files = {name: z.read(name) for name in z.namelist() if name not in ['xl/sharedStrings.xml', 'xl/worksheets/sheet1.xml']}

    ns = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
    ET.register_namespace('', ns['s'])

    shared_root = ET.fromstring(shared_xml)
    sheet_root = ET.fromstring(sheet_xml)

    existing_strings = [t.text for t in shared_root.findall('.//s:t', ns)]
    
    def get_str_idx(val):
        val = str(val or '')
        if val in existing_strings:
            return str(existing_strings.index(val))
        else:
            si = ET.SubElement(shared_root, '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si')
            t = ET.SubElement(si, '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t')
            t.text = val
            existing_strings.append(val)
            return str(len(existing_strings) - 1)

    sheet_data = sheet_root.find('s:sheetData', ns)
    rows = sheet_data.findall('s:row', ns)
    row_count = len(rows)
    s_no = str(row_count)
    new_row_idx = row_count + 1

    new_row = ET.Element('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row', {'r': str(new_row_idx)})

    values = [
        s_no,
        roll_number,
        full_name,
        current_year,
        branch,
        college_name,
        email,
        mobile_number,
        domain,
        mode,
        team_name
    ]

    cols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']

    for col, val in zip(cols, values):
        idx = get_str_idx(val)
        c = ET.SubElement(new_row, '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c', {
            'r': f'{col}{new_row_idx}',
            't': 's'
        })
        v = ET.SubElement(c, '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
        v.text = idx

    sheet_data.append(new_row)

    shared_root.set('count', str(len(existing_strings)))
    shared_root.set('uniqueCount', str(len(existing_strings)))

    new_shared_xml = ET.tostring(shared_root, encoding='utf-8', xml_declaration=True)
    new_sheet_xml = ET.tostring(sheet_root, encoding='utf-8', xml_declaration=True)

    tmp_path = excel_path + '.tmp'
    with zipfile.ZipFile(tmp_path, 'w', zipfile.ZIP_DEFLATED) as zout:
        for name, data in zip_files.items():
            zout.writestr(name, data)
        zout.writestr('xl/sharedStrings.xml', new_shared_xml)
        zout.writestr('xl/worksheets/sheet1.xml', new_sheet_xml)

    os.replace(tmp_path, excel_path)
    print(f"SUCCESS: Appended row {new_row_idx} for {full_name} ({roll_number}) to Excel.")
    return True

if __name__ == '__main__':
    if len(sys.argv) < 11:
        print("Usage: python append_excel.py <excel_path> <roll_number> <full_name> <current_year> <branch> <college_name> <email> <mobile_number> <domain> <mode> [<team_name>]")
        sys.exit(1)

    excel_path = sys.argv[1]
    roll_number = sys.argv[2]
    full_name = sys.argv[3]
    current_year = sys.argv[4]
    branch = sys.argv[5]
    college_name = sys.argv[6]
    email = sys.argv[7]
    mobile_number = sys.argv[8]
    domain = sys.argv[9]
    mode = sys.argv[10]
    team_name = sys.argv[11] if len(sys.argv) > 11 else ""

    append_to_hackathon_excel(excel_path, roll_number, full_name, current_year, branch, college_name, email, mobile_number, domain, mode, team_name)

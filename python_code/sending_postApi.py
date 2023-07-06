# import modules
from faker import Faker
from fpdf import FPDF
import requests
import time

def fakeText():
    ''' return randoms strings '''
    para=fake.paragraphs(nb=10)
    return ' '.join(para)


def fakeResumeFile():
    ''' create a random pdf and return in bytes string'''
    pdf=FPDF()
    pdf.add_page()
    pdf.set_font('Times', '', 12)
    pdf.set_title('Resume')
    pdf.multi_cell(0,10,txt=fakeText())
    return pdf.output(dest='S').encode('latin-1')


fake=Faker(locale='en_IN')
def makeFake():
    ''' generate random data and return as dictionary 
        data={
            'fullname':first_name+" "+last_name,
            'gender':''.join(gender),
            'from_date':from_date,
            'to_date':to_date,
            'email':email,
            'number':number,
        }
    '''
    # gender
    genders=['Male','Female','Others']
    gender=genders[fake.pyint(0,2)]
    # first name
    first_name = (fake.first_name_male() if gender == 'Male' else fake.first_name_female()).strip()
    # last name
    last_name = fake.last_name()
    # email
    email=f'{first_name}@xenonstack.com'
    # number
    number = fake.phone_number()[-10:]
    # dates
    from_date=fake.date()
    to_date = fake.date_between(start_date='-5y')
    to_date=str(to_date)
    while from_date>to_date:
        from_date=fake.date()
        to_date = fake.date()
    data={
        'fullname':first_name+" "+last_name,
        'gender':''.join(gender),
        'from_date':from_date,
        'to_date':to_date,
        'email':email,
        'number':number,
    }
    return data


# post api url
api_url='http://localhost:8080/api/v1'
for _ in range(5):
    time.sleep(3)
    files=fakeResumeFile()
    data=makeFake()
    name=data['fullname'].split(' ')[0]
    requests.post(api_url,data=data,files={'resume': (f'{name}.pdf', files, 'application/pdf')})
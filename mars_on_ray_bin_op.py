from mars.session import new_session
ray_session = new_session().as_default()

import mars.tensor as mt

t1 = mt.random.rand(5, 4, chunk_size=2)
t2 = mt.random.rand(5, 4, chunk_size=3)
print((t1 + t2).execute())
